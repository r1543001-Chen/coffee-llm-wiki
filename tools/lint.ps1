# Wiki lint：檢查來源標記、內部連結、index 收錄、孤兒頁、缺來源的條列句。
# 用法（在專案根目錄）：powershell -ExecutionPolicy Bypass -File tools\lint.ps1
$ErrorActionPreference = 'Stop'
$root  = Split-Path -Parent $PSScriptRoot
$wiki  = Join-Path $root 'wiki'
$pages = Get-ChildItem $wiki -Recurse -Filter *.md
$sourceIds = (Get-ChildItem (Join-Path $wiki 'sources') -Filter *.md).BaseName
$problems = New-Object System.Collections.Generic.List[string]
$inbound  = @{}
foreach ($p in $pages) { $inbound[$p.FullName] = 0 }

foreach ($p in $pages) {
    $rel   = $p.FullName.Substring($wiki.Length + 1)
    $lines = [System.IO.File]::ReadAllLines($p.FullName, [System.Text.Encoding]::UTF8)
    $n = 0
    foreach ($line in $lines) {
        $n++
        # 1. 來源標記必須對應到 sources/ 裡的頁面
        foreach ($m in [regex]::Matches($line, '\[來源: ([a-z0-9-]+)')) {
            if ($sourceIds -notcontains $m.Groups[1].Value) {
                $problems.Add("[來源不存在] ${rel}:$n -> $($m.Groups[1].Value)")
            }
        }
        # 2. 內部連結必須指向存在的檔案
        foreach ($m in [regex]::Matches($line, '\]\(([^)#]+\.md)\)')) {
            $target = [System.IO.Path]::GetFullPath((Join-Path $p.DirectoryName $m.Groups[1].Value))
            if (-not (Test-Path $target)) {
                $problems.Add("[連結失效] ${rel}:$n -> $($m.Groups[1].Value)")
            } elseif ($target -ne $p.FullName -and $inbound.ContainsKey($target)) {
                $inbound[$target]++
            }
        }
        # 3. 概念頁與來源頁的條列事實句必須有來源標記或 (推論)
        $isFactPage = $rel -like 'concepts*' -or $rel -like 'sources*'
        if ($isFactPage -and $line -match '^\s*- ' -and $line -notmatch '\[來源: ' -and $line -notmatch '\(推論' ) {
            $exempt = $line -match '^\s*- \*\*(標題|作者|期刊|DOI|原檔|研究類型)\*\*' -or
                      $line -match '\]\(.+\.md\)' -or
                      $line -match '\*\*(知識缺口|重要)\*\*' -or
                      $line -match '：\s*$'
            $inInconsistency = $false
            for ($k = $n - 1; $k -ge 1; $k--) {
                if ($lines[$k - 1] -match '^## ') { $inInconsistency = $lines[$k - 1] -match '原文內部不一致'; break }
            }
            if (-not $exempt -and -not $inInconsistency) {
                $problems.Add("[缺來源] ${rel}:$n $($line.Trim())")
            }
        }
    }
}

# 4. 每一頁都要列在 index.md
$indexText = [System.IO.File]::ReadAllText((Join-Path $wiki 'index.md'), [System.Text.Encoding]::UTF8)
foreach ($p in $pages) {
    if ($p.Name -eq 'index.md') { continue }
    $relLink = $p.FullName.Substring($wiki.Length + 1).Replace('\', '/')
    if ($indexText -notmatch [regex]::Escape($relLink)) { $problems.Add("[未列入 index] $relLink") }
}

# 5. 孤兒頁：除了 index 之外沒有任何頁面連到它
foreach ($p in $pages) {
    if ($p.Name -in 'index.md', 'log.md') { continue }
    if ($inbound[$p.FullName] -lt 2) {
        $problems.Add("[連入過少] $($p.FullName.Substring($wiki.Length + 1)) 只有 $($inbound[$p.FullName]) 個連入")
    }
}

"檢查 $($pages.Count) 頁，來源 $($sourceIds.Count) 篇"
if ($problems.Count -eq 0) { 'LINT 通過：0 個問題' } else { $problems; "LINT 未通過：$($problems.Count) 個問題"; exit 1 }
