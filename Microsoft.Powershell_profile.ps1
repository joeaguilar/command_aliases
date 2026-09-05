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
# Prefer the official SQLite CLI (fts5 + .recover) over the vendor copies that
# come earlier on PATH (Android SDK, Nsight). Cheap check, no probing at startup.
$__sqliteOfficial = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\SQLite.SQLite*\sqlite3.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($__sqliteOfficial) { Set-Alias sqlite3 $__sqliteOfficial.FullName }

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

# Get-OpenWith <path>: programs Windows lists under "Open with" for the file's
#   extension (HKCU FileExts + HKCR OpenWithList/OpenWithProgids + default handler),
#   resolved to Exe + Args where %1 stands for the file.  Store apps (AppX) are
#   skipped: they have no command line.  Dedupes by exe name, drops dead paths.
function Get-OpenWith([string]$Path) {
    $ext = [IO.Path]::GetExtension($Path)
    if (-not $ext) { return }
    $cr = 'Registry::HKEY_CLASSES_ROOT'
    $fx = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\$ext"
    $exes = @(); $progids = @()
    $k = Get-Item "$fx\OpenWithList" -ErrorAction SilentlyContinue
    if ($k) { $exes += $k.GetValueNames() | Where-Object { $_ -ne 'MRUList' } | ForEach-Object { $k.GetValue($_) } }
    $k = Get-Item "$cr\$ext\OpenWithList" -ErrorAction SilentlyContinue
    if ($k) { $exes += $k.GetSubKeyNames() }
    foreach ($p in "$fx\OpenWithProgids", "$cr\$ext\OpenWithProgids") {
        $k = Get-Item $p -ErrorAction SilentlyContinue
        if ($k) { $progids += $k.GetValueNames() }
    }
    $progids += (Get-ItemProperty "$cr\$ext" -ErrorAction SilentlyContinue).'(default)'
    $progids += (Get-ItemProperty "$fx\UserChoice" -ErrorAction SilentlyContinue).ProgId
    $cmds = @()
    foreach ($e in $exes) {
        $c = (Get-ItemProperty "$cr\Applications\$e\shell\open\command" -ErrorAction SilentlyContinue).'(default)'
        if (-not $c) {
            $ap = (Get-ItemProperty "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$e" -ErrorAction SilentlyContinue).'(default)'
            if ($ap) { $c = "`"$ap`" `"%1`"" }
        }
        if ($c) { $cmds += $c }
    }
    foreach ($p in $progids | Where-Object { $_ -and $_ -notlike 'AppX*' }) {
        $c = (Get-ItemProperty "$cr\$p\shell\open\command" -ErrorAction SilentlyContinue).'(default)'
        if ($c) { $cmds += $c }
    }
    $seen = @{}
    foreach ($c in $cmds) {
        $c = [Environment]::ExpandEnvironmentVariables($c)
        if ($c -notmatch '%[1L]') { continue }                        # e.g. devenv /dde: no file slot
        if ($c -notmatch '^\s*"?(.+?\.exe)"?\s*(.*)$') { continue }   # handles unquoted paths with spaces
        $exe = $Matches[1]; $rest = $Matches[2]
        $label = [IO.Path]::GetFileNameWithoutExtension($exe).ToLower()
        if ($seen[$label] -or -not (Test-Path -LiteralPath $exe)) { continue }
        $seen[$label] = 1
        [pscustomobject]@{ Label = $label; Exe = $exe; Args = $rest }
    }
}

# fo: fuzzy-pick a project, then a file inside it, then a program to open it with
function fo {
    # stage 1: directory (same as work/gopro)
    $root = "$env:USERPROFILE\AI\AI_projects"
    $pick = Get-ChildItem $root -Directory | Select-Object -ExpandProperty Name |
        fzf --prompt 'dir> ' --preview "dir /b `"$root\{}`""
    if (-not $pick) { return }
    $dir = Join-Path $root $pick

    # stage 2: file (rg --files honours .gitignore, so node_modules/.git stay out;
    #          fall back to Get-ChildItem when rg isn't installed)
    $files = if (Get-Command rg -ErrorAction SilentlyContinue) { rg --files $dir }
             else { Get-ChildItem $dir -File -Recurse | Select-Object -ExpandProperty FullName }
    $file = $files | ForEach-Object { $_.Substring($dir.Length + 1) } |
        fzf --prompt 'file> ' --preview "type `"$dir\{}`""
    if (-not $file) { return }
    $path = Join-Path $dir $file

    # stage 3: program.  Three sources, in this order:
    #   hand table (only those installed)  ->  Windows "Open with" list for this
    #   extension (see Get-OpenWith)  ->  explorer / default, which always apply
    $hand = [ordered]@{
        'code'    = { code $args[0] }
        'nvim'    = { nvim $args[0] }
        'notepad' = { notepad $args[0] }
    }
    $apps = [ordered]@{}
    foreach ($k in $hand.Keys) { if (Get-Command $k -ErrorAction SilentlyContinue) { $apps[$k] = $hand[$k] } }
    $reg = @{}
    foreach ($o in Get-OpenWith $path) {
        if (-not $apps.Contains($o.Label)) { $reg[$o.Label] = $o; $apps[$o.Label] = $null }
    }
    $apps['explorer'] = { explorer.exe /select,$args[0] }
    $apps['default']  = { Start-Process $args[0] }   # whatever Windows associates
    $app = $apps.Keys | fzf --prompt 'open with> ' --header $file --height 80% `
        --preview "type `"$path`"" --preview-window 'right,70%,wrap'
    if (-not $app) { return }
    if ($apps[$app]) { & $apps[$app] $path }
    else { $o = $reg[$app]; Start-Process $o.Exe -ArgumentList ($o.Args -replace '"?%[1L]"?', "`"$path`"") }
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

# --- itr repair -----------------------------------------------------------------
# Find-Sqlite3: pick the most capable sqlite3.exe on this machine. Vendor copies
#   (Android SDK, Nsight, Apache) lack fts5 and .recover; the official build from
#   `winget install SQLite.SQLite` has both. Result is cached for the session.
function Find-Sqlite3([switch]$Refresh) {
    if ($global:__sqlite3 -and -not $Refresh -and (Test-Path $global:__sqlite3.Path)) { return $global:__sqlite3 }
    $cands = @(where.exe sqlite3 2>$null) +
             @(Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\SQLite.SQLite*" -Recurse -Filter sqlite3.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName) |
             Where-Object { $_ } | Select-Object -Unique
    $found = foreach ($exe in $cands) {
        # -batch and "< nul" so a probe can never sit waiting for interactive input
        $ver  = ((cmd /c "`"$exe`" -version < nul 2>&1") -split ' ')[0]
        $fts5 = ((cmd /c "`"$exe`" -batch :memory: `"CREATE VIRTUAL TABLE t USING fts5(x); SELECT 'yes';`" < nul 2>&1") -join '') -eq 'yes'
        $rec  = ((cmd /c "`"$exe`" -batch :memory: .recover < nul 2>&1") -join '') -notmatch 'unknown command'
        [pscustomobject]@{ Path = $exe; Version = [version]$ver; Fts5 = $fts5; Recover = $rec }
    }
    $global:__sqlite3 = $found | Sort-Object Recover, Fts5, Version -Descending | Select-Object -First 1
    $global:__sqlite3
}

# itrfix [-Apply]: diagnose a corrupt .itr.db and pick the best restore source.
#   Candidates: git HEAD, git origin/main (after fetch), and a salvage rebuild of
#   whatever sqlite3 can still read (.recover when available, else .dump).
#   Dry run by default; -Apply replaces the db, then runs itr reindex + itr doctor.
#   The corrupt file is always backed up first.
function itrfix([switch]$Apply, [string]$Db = '.itr.db') {
    if (-not (Test-Path $Db)) { Write-Warning "no $Db here"; return }
    $sq = Find-Sqlite3
    if (-not $sq) { Write-Warning 'no sqlite3.exe found; winget install SQLite.SQLite'; return }
    "sqlite3: $($sq.Path) (v$($sq.Version), fts5=$($sq.Fts5), recover=$($sq.Recover))"
    $Db    = (Resolve-Path $Db).Path
    $dir   = Split-Path $Db
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $tmp   = Join-Path $env:TEMP "itrfix-$stamp"
    New-Item -ItemType Directory $tmp | Out-Null

    function probe($path, $name) {
        $ok = (& $sq.Path -batch $path 'PRAGMA integrity_check;' 2>&1 | Select-Object -First 1) -eq 'ok'
        $m  = & $sq.Path -batch $path "SELECT COUNT(*)||'|'||IFNULL(MAX(updated_at),'')||'|'||(SELECT IFNULL(MAX(created_at),'') FROM events) FROM issues;" 2>$null
        $p  = "$m".Split('|') + @('', '', '')
        [pscustomobject]@{ Source = $name; Healthy = $ok; Issues = $p[0]; LastIssueUpdate = $p[1]; LastEvent = $p[2]; Path = $path }
    }

    $current = probe $Db 'current'
    if ($current.Healthy) { "integrity ok, nothing to repair"; itr doctor; return }
    Write-Host "integrity check FAILED on $Db" -ForegroundColor Yellow
    $backup = "$Db.corrupt-$stamp"
    Copy-Item $Db $backup
    "backup: $backup"

    $cands = @()
    # 1. committed copies from git
    $rel = git -C $dir ls-files --full-name (Split-Path -Leaf $Db) 2>$null
    if ($rel) {
        git -C $dir fetch -q 2>$null
        foreach ($ref in 'HEAD', 'origin/main') {
            if (-not (git -C $dir rev-parse -q --verify "${ref}:$rel" 2>$null)) { continue }
            $out = Join-Path $tmp ("git-" + ($ref -replace '[/:]', '_') + ".db")
            Start-Process git -ArgumentList @('-C', "`"$dir`"", 'cat-file', '-p', "${ref}:$rel") -RedirectStandardOutput $out -NoNewWindow -Wait
            $cands += probe $out "git $ref"
        }
    }
    # 2. salvage: .recover walks the raw pages and rescues orphaned rows into
    #    lost_and_found; .dump is the fallback. Either way drop the FTS index and
    #    the transaction wrapper, and load with INSERT OR IGNORE to skip bad rows.
    $dump = Join-Path $tmp 'dump.sql'
    $mode = if ($sq.Recover) { '.recover' } else { '.dump' }
    Start-Process $sq.Path -ArgumentList @('-batch', "`"$Db`"", $mode) -RedirectStandardOutput $dump -NoNewWindow -Wait
    "salvage via $mode"
    $skipUntil = $null   # regex that ends the FTS statement currently being skipped
    $clean = foreach ($line in [IO.File]::ReadAllLines($dump)) {
        if ($skipUntil) { if ($line -match $skipUntil) { $skipUntil = $null }; continue }
        if ($line -match '_fts') {
            if ($line -match '\bBEGIN\s*$')                { $skipUntil = '^END;' }   # FTS trigger body
            elseif (-not $line.TrimEnd().EndsWith(';'))    { $skipUntil = ';\s*$' }  # multi-line statement
            continue
        }
        # .dump wraps in BEGIN TRANSACTION/COMMIT (or ROLLBACK on error), .recover in BEGIN/COMMIT;
        # a trigger body's bare BEGIN has no semicolon and must be kept
        if ($line -match '^(BEGIN( TRANSACTION)?|COMMIT|ROLLBACK)\s*;') { continue }
        $line -replace '^INSERT INTO', 'INSERT OR IGNORE INTO'
    }
    $cleanSql = Join-Path $tmp 'dump.clean.sql'
    [IO.File]::WriteAllLines($cleanSql, $clean, (New-Object Text.UTF8Encoding $false))
    $salv = Join-Path $tmp 'salvage.db'
    & $sq.Path -batch $salv ".read $($cleanSql -replace '\\', '/')" 2>$null | Out-Null
    # .recover keeps whatever it can decode, junk cells included; drop rows whose
    # column types contradict the declared schema so itr can open the result
    foreach ($tbl in 'issues', 'notes', 'events', 'dependencies', 'relations') {
        $preds = foreach ($c in @(& $sq.Path -batch $salv "PRAGMA table_info($tbl);" 2>$null)) {
            $f = $c.Split('|'); $name = $f[1]; $type = $f[2].ToUpper()
            if     ($type -match 'INT')       { "typeof(`"$name`") NOT IN ('integer','null')" }
            elseif ($type -match 'TEXT|CHAR') { "typeof(`"$name`") NOT IN ('text','null')" }
        }
        if ($preds) { & $sq.Path -batch $salv "DELETE FROM $tbl WHERE $($preds -join ' OR ');" 2>$null | Out-Null }
    }
    itr reindex --db $salv -q 2>$null | Out-Null
    $cands += probe $salv 'salvage'

    $all = @($current) + $cands
    $all | Format-Table Source, Healthy, Issues, LastIssueUpdate, LastEvent -AutoSize | Out-String | Write-Host
    $best = $cands | Where-Object Healthy | Sort-Object LastEvent, Issues -Descending | Select-Object -First 1
    if (-not $best) { Write-Warning 'no healthy candidate found; salvage output left in ' + $tmp; return }
    "best source: $($best.Source)"

    # anything readable in the wreck that the chosen source lacks?
    $salvPath = ($cands | Where-Object Source -eq 'salvage').Path
    if ($best.Source -ne 'salvage' -and (Test-Path $salvPath)) {
        $newer = & $sq.Path -batch $salvPath "ATTACH '$($best.Path -replace '\\', '/')' AS b; SELECT w.id FROM main.issues w LEFT JOIN b.issues x ON x.id = w.id WHERE x.id IS NULL OR w.updated_at > x.updated_at;" 2>$null
        if ($newer) { Write-Warning ("issues in the corrupt copy missing/newer than $($best.Source): " + ($newer -join ', ') + "  (salvage db: $salvPath)") }
    }

    if (-not $Apply) { "dry run: re-run with -Apply to restore from $($best.Source)"; return }
    Copy-Item $best.Path $Db -Force
    "restored $Db from $($best.Source)"
    itr reindex
    itr doctor
}

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

# fcd: walk directories in fzf. Pick a folder to descend, '..' to go up,
#      '.' to cd into the shown path. Esc aborts and leaves you where you were.
function fcd {
    $cur = (Get-Location).Path
    while ($true) {
        $parent  = Split-Path $cur -Parent            # '' at a drive root
        $entries = @('.')
        if ($parent) { $entries += '..' }
        $entries += Get-ChildItem -LiteralPath $cur -Directory -Force |
            Select-Object -ExpandProperty Name
        $pick = $entries | fzf --prompt 'cd> ' --header $cur --no-sort `
            --preview "dir /b `"$cur\{}`""
        if (-not $pick) { return }                    # Esc or Ctrl-C: go nowhere
        switch ($pick) {
            '.'     { Set-Location -LiteralPath $cur; return }
            '..'    { $cur = $parent }
            default { $cur = Join-Path $cur $pick }
        }
    }
}

# --- Editing this file --------------------------------------------------------
function alias { code $PROFILE }

Write-Host "Profile loaded" -ForegroundColor DarkGray

