# Log

時間序紀錄，只增不改。格式見 [AGENTS.md](../AGENTS.md) 第 6 節。

## [2026-11-24] setup | 討論與定案

- 經討論後定案：主題「一杯好咖啡的四個變數」，以論文為來源，wiki 用繁體中文。
- 選定 5 篇：Hendon 2014（水質）、Uman 2016（研磨）、Batali 2020（水溫）、Moroney 2016（時間）、Guinard 2023（整合）。
- 候選清單在查證階段修正一處：沖煮控制圖論文的年份，AI 原先憑記憶說 2020，查證後為 2023。
- 使用者指示 ingest「一次跑完」，因此省略逐篇討論的步驟。

## [2026-11-24] fetch | 下載 5 篇論文

- 第一次嘗試：5 篇中只有 Guinard 2023 成功。
  - Hendon 2014（core.ac.uk）：403。
  - Uman 2016、Batali 2020（nature.com）、Moroney 2016（springeropen.com）：回傳 3038 bytes 的 HTML 驗證頁，但被存成 `.pdf`。**檢查檔頭後才發現不是 PDF。**
- 第二次嘗試：Europe PMC 的 PDF 連結，三篇都 403。
- 第三次嘗試：改用 Europe PMC 官方 API 的 `fullTextXML`，三篇開放取用論文成功取得全文 XML。
- Hendon 2014：改試 Bath 大學機構典藏，直接下載與用瀏覽器開啟都遇到機器人驗證頁。**依規則停止，不繞過**，列為待人工下載。
- 為維持「至少 5 篇」並補上水質這個變數，新增 Bratthäll 2024（開放授權，同樣經 Europe PMC API 取得）。這篇原本是備選。
- 結果：`raw/` 有 5 個檔案（編號 02–06），01 從缺。

## [2026-11-24] schema | AGENTS.md v1 → v2

- 新增 5.1「取得資料」：下載後檢查檔頭與大小；遇到驗證牆就停。
- 新增寫作規則 4（二手引用）與規則 6 的書目部分。
- 來源頁格式新增「原文內部不一致」欄位。

## [2026-11-24] ingest | Uman 2016

- 新增 `sources/uman-2016.md`，新增 `concepts/grind.md`。
- 檢查點 A 發現：原文方法段說溫度實驗用瓜地馬拉豆，圖 4 圖說寫薩爾瓦多豆。處理：wiki 不指明產地，並記錄在來源頁。
- 檢查點 A 發現：XML 轉文字時作者欄是空的（XPath 沒處理到）。處理：改寫查詢後從原檔重新取出作者，沒有憑記憶填。

## [2026-11-24] ingest | Batali 2020

- 新增 `sources/batali-2020.md`，新增 `concepts/brew-temperature.md`、`concepts/tds.md`、`concepts/extraction-yield.md`。
- 檢查點 A 發現：原文寫「八項屬性」但列出九項。記錄在來源頁，wiki 不引用這個計數。
- 寫作時特別處理：結論的適用範圍（87–93°C、滴濾）寫進每一處引用，避免變成「水溫不重要」。

## [2026-11-24] ingest | Moroney 2016

- 新增 `sources/moroney-2016.md`，新增 `concepts/brew-time.md`，更新 `concepts/grind.md`、`concepts/extraction-yield.md`。
- 數學推導（漸近展開）不寫入 wiki，只取物理結論與時間尺度數字。
- 注意到的陷阱：Moroney 的「快慢」是顆粒表面與內部，Batali 的「快慢」是不同化學成分。寫入 `brew-time.md` 的爭議段，避免混為一談。

## [2026-11-24] ingest | Guinard 2023

- 新增 `sources/guinard-2023.md`，新增 `concepts/brewing-control-chart.md`、`concepts/brew-ratio.md`，更新 `concepts/tds.md`、`concepts/extraction-yield.md`。
- 檢查點 A 發現：本文說 Batali 2020 評估 33 項屬性，Batali 原文寫 31 項。處理：採用原始論文的數字，兩個來源頁都註記。
- Frost 2020、Cotter 2021 未 ingest，相關內容都標為轉述。

## [2026-11-24] ingest | Bratthäll 2024

- 新增 `sources/bratthall-2024.md`，新增 `concepts/water-quality.md`，更新 `concepts/brew-time.md`。
- 與 Hendon 2014 的牴觸寫入 `water-quality.md` 的爭議段。Hendon 一欄標明是二手轉述。

## [2026-11-24] query | 常見說法哪些有研究支持？

- 讀 index 與 8 個概念頁後回答，存為 `synthesis/myths-vs-research.md`。

## [2026-11-24] query | 外行人需要知道什麼？（簡報大綱）

- 存為 `synthesis/slides-outline.md`，15 頁。
- 檢查點 B：大綱不納入兩類 wiki 無法支持的內容——「水溫高要磨粗」之類的操作建議，以及手沖的建議時間與水溫。這些屬於 AI 的背景知識，不在 wiki 裡。

## [2026-11-24] lint | 全庫第一次檢查

- 執行 `tools/lint.ps1`：17 頁，3 個問題。
  - `concepts/brew-time.md`、`concepts/extraction-yield.md` 各有一句綜合判斷沒有標來源也沒有標 (推論)。處理：補上 (推論) 標記。
  - `synthesis/slides-outline.md` 只有 index 連到它。處理：從 `myths-vs-research.md` 加上連結。
- 另外發現腳本本身的問題：PowerShell 5.1 讀不到無 BOM 的 UTF-8 中文，需存成帶 BOM 的 UTF-8。
- 修正後重跑：通過，0 個問題。

## [2026-11-24] slides | 產生 slides/index.html

- 依 `synthesis/slides-outline.md` 產生 15 頁簡報，每頁下方標示對應的 wiki 頁與論文。
- 檢查點 D（瀏覽器實測）第一輪：以程式量測每頁內容底部與頁尾的距離，第 15 頁溢出 77 px。處理：只縮小該頁表格的字級與間距。
- 第二輪：15 頁全部無溢出。另目視檢查第 1、3、6、11、12、15 頁的截圖。
- 預覽環境中發現兩個問題並修正：更新網址的呼叫加上例外處理；縮放改為同時監聽視窗大小變化。

## [2026-11-24] fetch | Hendon 2014（人工下載）

- 使用者手動從 Bath 大學機構典藏下載，放入 `raw/01-hendon-2014-water-cations.pdf`。
- 檔案檢查：檔頭 `%PDF`，756 KB，內含期刊版全文 4 頁。通過。

## [2026-11-24] ingest | Hendon 2014

- 新增 `sources/hendon-2014.md`。
- 重寫 `concepts/water-quality.md`：對照表左欄由二手轉述改為直接引用；新增鈉的發現、SCAE 300 ppm 上限、「結合能不等於萃取量」的限制，以及兩篇研究重疊範圍（四種有機酸）的分析。
- 更新 `sources/bratthall-2024.md`、`concepts/tds.md`、`synthesis/myths-vs-research.md`（新增軟水器一列，共十列）、`index.md`。全庫已無二手轉述 Hendon 的標記。
- **核對先前的二手轉述**：Bratthäll 對 Hendon 的描述準確，但省略三點——氣相計算、作者自己說需實驗驗證、就風味平衡而言鈣與鎂相當。wiki 先前依轉述寫的內容沒有錯，但不完整。
- 檢查點 A 發現：原文把自己的計算稱為「熱力學實驗」。記錄在來源頁，wiki 一律稱為計算。
- 新發現的用詞陷阱：水質文獻的「TDS」是水中礦物質，不是咖啡液濃度。已在 `tds.md` 與 `water-quality.md` 註明。

## [2026-11-24] slides | 依 Hendon 2014 更新簡報

- 大綱第 10、15 列更新。簡報第 9、10、13、15 頁更新：移除「二手轉述」標記，對照表改列方法、對象、結論。
