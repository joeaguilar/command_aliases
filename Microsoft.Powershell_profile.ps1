# PowerShell profile (PowerShell 5.1)
# Converted from command_aliases\aliases.cmd and command_aliases\bash_profile.sh
# Reload with:  rel

# --- Reload -----------------------------------------------------------------
# Functions run in a child scope, so a plain ". $PROFILE" inside a function
# would define everything locally and lose it on return. This re-sources the
# profile and promotes what it defined up to global scope.
function rel {
    $before = @{ a = (Get-ChildItem alias:).Name; v = (Get-Variable -Scope 0).Name }
    . $PROFILE
    Get-ChildItem function: | Where-Object { $_.ScriptBlock.File -eq $PROFILE } |
        ForEach-Object { Set-Item "function:global:$($_.Name)" $_.ScriptBlock }
    Get-ChildItem alias:    | Where-Object Name -notin $before.a |
        ForEach-Object { Set-Alias $_.Name $_.Definition -Scope Global -Force }
    Get-Variable -Scope 0   | Where-Object Name -notin $before.v |
        ForEach-Object { Set-Variable $_.Name $_.Value -Scope Global -Force }
}

# # --- Built-in aliases that shadow our functions ------------------------------
# # Aliases take precedence over functions. 'gl' is Get-Location by default.
# if (Test-Path alias:gl) { Remove-Item alias:gl -Force }

# --- Environment --------------------------------------------------------------
$env:EDITOR = "code"
# PowerShell sets no HOME, so ccq cannot find ~/.claude/projects on its own
$env:CCQ_ROOT = "$env:USERPROFILE\.claude\projects"

# --- Movement -----------------------------------------------------------------
function ..     { Set-Location .. }
function ...    { Set-Location ..\.. }
function ....   { Set-Location ..\..\.. }
function .....  { Set-Location ..\..\..\.. }
# function gohome { Set-Location $env:USERPROFILE }
function godown { Set-Location "$env:USERPROFILE\Downloads" }
function proj   { Set-Location "$env:USERPROFILE\AI\AI_projects" }

# --- Look ---------------------------------------------------------------------
# ll: everything incl. hidden, oldest first (like ls -hAlTFtr)
function ll   { Get-ChildItem -Force @args | Sort-Object LastWriteTime }
# lt: by modified time, newest last
function lt   { Get-ChildItem @args | Sort-Object LastWriteTime }
# lr: reverse name order
function lr   { Get-ChildItem @args | Sort-Object Name -Descending }
# ldir: directories only ('ld' is the mingw linker on PATH)
function ldir { Get-ChildItem -Directory -Force @args }

# --- Date / time --------------------------------------------------------------
function nowdate { Get-Date -Format "dd-MM-yyyy" }
function nowtime { Get-Date -Format "HH:mm:ss" }

# --- Git ----------------------------------------------------------------------
function g    { git @args }
function gs   { git status }
function gsp  { git status --porcelain }
function gf   { git fetch @args }
function gl   { git log --oneline --decorate @args }
function gg   { git log --graph --all --oneline --decorate @args }
# function gla  { git log --author @args }
function gd   { git diff @args }
function gds  { git diff --staged @args }
function gdl  { git diff --color-words @args }
function gdls { git diff --color-words --staged @args }
function gsh  { git show --color-words @args }
function gco  { git checkout @args }
function gad  { git add @args }
function gap  { git add -p @args }
function gun  { git restore --staged @args }
function gup  { git restore --staged -p @args }
function grs  { git reset @args }
function grss { git reset --soft @args }
function gst  { git stash @args }
function gstl { git stash list }
function gb   { git branch @args }
function gbm  { git branch --merged }
function gbn  { git branch --no-merged }

# skip-worktree: hide local changes to tracked files from git
function gitskiplist { git ls-files -v | Select-String '^S' }
function gitskip     { git update-index --skip-worktree @args;    gitskiplist }
function gitunskip   { git update-index --no-skip-worktree @args; gitskiplist }

# --- npm ----------------------------------------------------------------------
function npmd { npm run dev @args }
function npmb { npm run build @args }
function npms { npm run start @args }

# --- Fuzzy finder (fzf + PSFzf) -----------------------------------------------
# Ctrl+T  file/folder picker    Ctrl+R  history search
# Alt+C   cd into a folder      fz      fuzzy Set-Location
# **<Tab> fzf completion for paths and git args (e.g.  gco **<Tab>)
# frg <text>  ripgrep into fzf, Enter opens the hit in $env:EDITOR
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PsFzfOption -TabExpansion
    # fd lists files/dirs for Ctrl+T and Alt+C: faster, honors .gitignore, skips hidden
    if (Get-Command fd -ErrorAction SilentlyContinue) { Set-PsFzfOption -EnableFd }
    Set-Alias fz  Invoke-FuzzySetLocation
    Set-Alias frg Invoke-PsFzfRipgrep
    $env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border'
}

# gopro: pick a project under AI_projects in fzf, cd into it, show the itr briefing
function gopro {
    $root = "$env:USERPROFILE\AI\AI_projects"
    $pick = Get-ChildItem $root -Directory | Select-Object -ExpandProperty Name |
        fzf --prompt 'project> ' --preview "dir /b `"$root\{}`""
    if ($pick) { Set-Location (Join-Path $root $pick); brief }
}

# brief: itr summary for the current project, minus the long RECENT tail
function brief {
    if (-not (Test-Path .itr.db)) { return }
    $out = @(itr summary 2>$null)
    $i = [array]::IndexOf($out, 'RECENT:')
    if ($i -gt 0) { $out[0..($i - 1)] } else { $out }
}

# work: pick a project and open a Windows Terminal window on it:
#       left pane runs claude, right pane is a plain shell
function work {
    $root = "$env:USERPROFILE\AI\AI_projects"
    $pick = Get-ChildItem $root -Directory | Select-Object -ExpandProperty Name |
        fzf --prompt 'work> ' --preview "dir /b `"$root\{}`""
    if (-not $pick) { return }
    $dir = Join-Path $root $pick
    Start-Process wt -ArgumentList "-d `"$dir`" powershell -NoLogo -NoExit -Command claude `; split-pane -V -d `"$dir`""
}

# ccr: fuzzy-pick a past Claude Code session and resume it
#      default = sessions for the current project;  ccr -All = every project
function ccr([switch]$All) {
    # ccq names project dirs by folding ':' '\' '_' in the path to '-'
    $scope = if ($All) { @() } else { @('-p', ($PWD.Path -replace '[:\\_]', '-')) }
    $rows = ccq sessions @scope -f tsv 2>$null | ConvertFrom-Csv -Delimiter "`t" | Sort-Object start -Descending
    if (-not $rows) { Write-Warning 'no sessions found'; return }
    $pick = $rows | ForEach-Object {
        '{0}  {1,-7} {2,3} msgs  {3,-20}  {4}' -f $_.start, $_.duration, $_.user_msgs, (Split-Path -Leaf $_.cwd), $_.session
    } | fzf --prompt 'resume> ' --preview 'ccq prompts -s {-1} --limit 8'
    if ($pick) { claude --resume ($pick -split '\s+')[-1] }
}

# fleet: one line per itr project: ready issues, in-progress, dirty files, unpushed commits
function fleet {
    $root = "$env:USERPROFILE\AI\AI_projects"
    $fmt = '{0,-16} {1,6} {2,6} {3,6} {4,9}  {5}'
    $fmt -f 'PROJECT', 'READY', 'WIP', 'DIRTY', 'UNPUSHED', 'BRANCH'
    foreach ($d in Get-ChildItem $root -Directory | Where-Object { Test-Path "$($_.FullName)\.itr.db" }) {
        Push-Location $d.FullName
        try {
            $s = itr stats -f json 2>$null | ConvertFrom-Json
            $ready  = if ($s) { $s.ready } else { 'err' }
            $wip    = if ($s) { $s.by_status.'in-progress' } else { 'err' }
            $dirty  = @(git status --porcelain 2>$null).Count
            $branch = git rev-parse --abbrev-ref HEAD 2>$null
            $upstream = git for-each-ref --format='%(upstream:short)' "refs/heads/$branch" 2>$null
            $up = if ($upstream) { git rev-list --count '@{u}..HEAD' 2>$null } else { '-' }
            $fmt -f $d.Name, $ready, $wip, $dirty, $up, $branch
        } finally { Pop-Location }
    }
}

# verify: run the project's test gate through gatr (auto-detects cargo / npm / pytest)
function verify {
    $cmd = if     (Test-Path Cargo.toml)     { 'cargo', 'test' }
           elseif (Test-Path package.json)   { 'npm.cmd', 'test' }
           elseif ((Test-Path pyproject.toml) -or (Test-Path pytest.ini)) { 'python', '-m', 'pytest' }
           else   { Write-Warning 'no Cargo.toml, package.json, or pyproject.toml here'; return }
    gatr run --tag test -- @cmd @args
}
function gerr { gatr errors }

# ks: fuzzy-pick a symbol from kgr, preview and print its definition
function ks {
    $pick = kgr symbols --no-progress 2>$null | Select-Object -Skip 2 |
        fzf --prompt 'symbol> ' --preview 'kgr show {2} 2>nul'
    if ($pick) { kgr show (($pick -split '\s+')[1]) 2>$null }
}

# kpi: fuzzy-pick a symbol from kgr, preview and print its transitive blast radius of changing
function kpi {
    $pick = kgr symbols --no-progress 2>$null | Select-Object -Skip 2 |
        fzf --prompt 'symbol> ' --preview 'kgr show {2} 2>nul'
    if ($pick) { kgr impact --no-progress (($pick -split '\s+')[1]) 2>$null }
}

# kimpact <symbol>: transitive blast radius of changing a symbol
# function kimpact { kgr impact --no-progress @args 2>$null }

# --- Shell utilities ------------------------------------------------------------
# renv: reload PATH from the registry (no shell restart after winget installs)
function renv {
    $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' +
                [Environment]::GetEnvironmentVariable('PATH', 'User')
    "PATH reloaded: $(@($env:PATH -split ';' | Where-Object { $_ }).Count) entries"
}
# open [path]: Explorer on the current (or given) folder
function open { explorer.exe (Resolve-Path $(if ($args) { $args[0] } else { '.' })).Path }
# killport <port>: kill whatever process owns a TCP port
function killport([int]$port) {
    $pids = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty OwningProcess -Unique
    if (-not $pids) { "nothing on :$port"; return }
    foreach ($id in $pids) {
        $p = Get-Process -Id $id -ErrorAction SilentlyContinue
        if ($p) { "killing $($p.ProcessName) (pid $id) on :$port"; Stop-Process -Id $id -Force }
    }
}
# gitroot: jump to the top of the current repo
function gitroot {
    $r = git rev-parse --show-toplevel 2>$null
    if ($r) { Set-Location $r } else { Write-Warning 'not in a git repo' }
}
# gbf: fuzzy-pick a branch and check it out ('gcb' is a native alias)
function gbf {
    $b = git branch --format='%(refname:short)' 2>$null |
        fzf --prompt 'branch> ' --preview 'git log --oneline --decorate -15 {}'
    if ($b) { git checkout $b }
}

# gohome: pick a folder under the user profile in fzf and cd into it
function gohome {
    $root = "$env:USERPROFILE"
    $pick = @('.') + (Get-ChildItem $root -Directory | Select-Object -ExpandProperty Name) |
        fzf --prompt 'home> ' --preview "dir /b `"$root\{}`""
    if ($pick) { Set-Location (Join-Path $root $pick) }
}

# --- Editing this file --------------------------------------------------------
function alias { code $PROFILE }

Write-Host "Profile loaded" -ForegroundColor DarkGray

