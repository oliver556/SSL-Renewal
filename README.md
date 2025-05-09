# SSL证书管理工具

这是一个用于管理SSL证书的工具，支持一键申请和自动续期功能。

## 功能特点

- 支持多个证书颁发机构（Let's Encrypt、Buypass、ZeroSSL）
- 自动续期管理
- 防火墙配置管理
- 证书申请失败自动清理
- 完整的日志记录

## 系统要求

- Linux系统（推荐Ubuntu/Debian）
- Root权限
- 已安装的依赖：
  - curl
  - git
  - socat
  - ufw（可选，用于防火墙管理）

## 安装方法

### 方式一：一键安装（需要root权限）

```bash
sudo bash <(curl -fsSL https://raw.githubusercontent.com/yourusername/SSL-Renewal/main/install.sh)
```

### 方式二：克隆仓库后安装（需要root权限）

1. 克隆仓库：
```bash
git clone https://github.com/yourusername/SSL-Renewal.git
cd SSL-Renewal
```

2. 运行安装脚本：
```bash
sudo ./install.sh
```

注意：安装脚本必须使用root权限运行，否则会提示错误并退出。

## 使用方法

运行主程序：
```bash
sudo ssl-manager
```

### 证书申请

1. 在主菜单中选择"申请SSL证书"
2. 输入域名和电子邮箱
3. 选择证书颁发机构
4. 等待证书申请完成

### 证书续期机制

证书续期采用自动管理机制，具体特点如下：

1. **续期时间阈值**：
   - 证书有效期为90天
   - 在证书到期前30天自动开始续期
   - 使用 `--days 30` 参数确保及时续期

2. **检查频率**：
   - 每天凌晨0点自动检查证书状态
   - 通过 crontab 实现定时任务
   - 检查脚本位置：`/etc/ssl/domains/<domain>/renew.sh`

3. **续期流程**：
   ```
   证书有效期90天
   │
   ├── 0天：证书签发
   │
   ├── 60天：开始检查续期（剩余30天）
   │   └── 如果续期失败，每天重试
   │
   └── 90天：证书过期
   ```

4. **日志记录**：
   - 续期日志保存在：`/var/log/ssl-renewal.log`
   - 记录每次续期检查的时间戳
   - 方便追踪续期历史

### 查看续期状态

1. 查看续期日志：
```bash
cat /var/log/ssl-renewal.log
```

2. 查看证书有效期：
```bash
openssl x509 -in /etc/ssl/certs/你的域名.crt -noout -dates
```

3. 手动测试续期：
```bash
/etc/ssl/domains/你的域名/renew.sh
```

### 证书存储位置

- 证书文件：`/etc/ssl/certs/<domain>.crt`
- 私钥文件：`/etc/ssl/private/<domain>.key`
- 域名配置：`/etc/ssl/domains/<domain>/`
  - 续期脚本：`renew.sh`
  - 配置信息：`config`

### 重置环境

如果需要清除所有申请记录并重新部署：
1. 在主菜单中选择"重置环境"
2. 确认操作
3. 系统将清理所有相关文件和配置

## 注意事项

1. 确保服务器时间准确，这对证书续期至关重要
2. 确保服务器能够访问证书颁发机构的服务器
3. 建议定期检查续期日志，确保续期正常进行
4. 如果续期失败，系统会每天重试，直到成功或证书过期

## 目录结构

```
SSL-Renewal/
├── README.md         # 项目说明
├── install.sh        # 安装脚本
└── ssl-manager       # 主程序脚本
```

## 贡献

欢迎提交 Issue 和 Pull Request 来帮助改进这个项目。

## 许可证

MIT License
