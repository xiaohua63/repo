import requests
import os

# 从环境变量中获取 GitHub API token
API_TOKEN = os.getenv('API_TOKEN')
OWNER = 'axs6'
REPO = 'repo'

# 确保 token 存在
if not API_TOKEN:
    raise ValueError("API_TOKEN is not set in the environment variables")

# Headers for authentication
headers = {
    'Authorization': f'token {API_TOKEN}',
    'Accept': 'application/vnd.github.v3+json'
}

# 获取最新发布的信息
response = requests.get(f'https://api.github.com/repos/{OWNER}/{REPO}/releases/latest', headers=headers)
release_info = response.json()

# 提取下载量和发布时间
download_count = release_info['assets'][0]['download_count']
release_date = release_info['published_at']

# 路径到你的 control 文件
control_file_path = 'control'

# 读取 control 文件
with open(control_file_path, 'r') as file:
    control_content = file.readlines()

# 写入更新后的 control 文件
with open(control_file_path, 'w') as file:
    for line in control_content:
        if line.startswith('Download-Count:'):
            file.write(f'Download-Count: {download_count}\n')
        elif line.startswith('Release-Date:'):
            file.write(f'Release-Date: {release_date}\n')
        else:
            file.write(line)
