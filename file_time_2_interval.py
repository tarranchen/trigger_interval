import pandas as pd
import os

def process_time_report(file_path="FileCreationTime_Report.csv"):
    """
    讀取並處理檔案建立時間報告。

    Args:
        file_path (str): CSV 檔案的路徑。
    """
    # 檢查檔案是否存在
    if not os.path.exists(file_path):
        print(f"錯誤：找不到檔案 '{file_path}'")
        return

    try:
        # 讀取 CSV 檔案
        df = pd.read_csv(file_path)

        # 第一步：篩選出檔名為 .pxm 的資料，並建立一個副本以避免 SettingWithCopyWarning
        df_pxm = df[df['FileName'].str.endswith('.pxm', na=False)].copy()

        # 如果沒有找到任何 .pxm 檔案，則提前結束
        if df_pxm.empty:
            print("在檔案中找不到任何 .pxm 結尾的項目。")
            # 可以選擇清空檔案或保留原樣，這裡選擇清空
            open(file_path, 'w').close()
            print(f"檔案 '{file_path}' 已被清空。")
            return

        # 將 'CreationTime (with ms)' 欄位轉換為 datetime 物件
        df_pxm.loc[:, 'CreationTime (with ms)'] = pd.to_datetime(df_pxm['CreationTime (with ms)'])

        # 第二步：計算時間間隔
        # diff() 會計算與前一行的差值，.dt.total_seconds() 轉換為秒
        time_intervals = df_pxm['CreationTime (with ms)'].diff().dt.total_seconds()

        # 將 Series 的資料類型改為 object，這樣才能同時存放數字和空字串
        df_pxm.loc[:, 'TimeInterval'] = time_intervals.astype(object)

        # 將第一個 .pxm 檔案的時間差 (原為 NaN) 設為空字串
        df_pxm.iloc[0, df_pxm.columns.get_loc('TimeInterval')] = ''

        # 第三步：格式化檔名
        # "PXMs_04_0000_0003.pxm" -> "0003.pxm"
        df_pxm.loc[:, 'FileName'] = df_pxm['FileName'].str.split('_').str[-1]

        # 準備最終要輸出的 DataFrame，只包含處理過的檔名和時間間隔
        output_df = df_pxm[['FileName', 'TimeInterval']]

        # 第四步：將結果存回原始檔案，不包含檔頭和索引
        output_df.to_csv(file_path, index=False, header=False)
        print(f"檔案 '{file_path}' 已成功處理並儲存。")

    except Exception as e:
        print(f"處理檔案時發生錯誤：{e}")

# --- 主程式執行區 ---
if __name__ == "__main__":
    # 執行處理函式，使用當前目錄下的 "FileCreationTime_Report.csv"
    process_time_report()
