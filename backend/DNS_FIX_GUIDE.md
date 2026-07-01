# DNS 解析超时问题解决方案

## 问题描述
```
io.netty.resolver.dns.DnsNameResolverTimeoutException: 
[18627: /192.168.23.4:53] DefaultDnsQuestion(api.deepseek.com. IN AAAA) 
query '18627' via UDP timed out after 5000 milliseconds
```

## 已实施的代码优化

### 1. application.yml 配置优化
- 增加了 WebClient 连接超时时间：30秒
- 增加了响应超时时间：60秒

### 2. WebClientConfig.java 配置类
- 创建了优化的 WebClient.Builder Bean
- 配置了连接池（最大50个连接）
- 添加了读写超时处理器
- 增加了连接超时和响应超时设置

## 系统级解决方案（需要手动操作）

如果上述代码优化后仍然出现 DNS 超时，请尝试以下系统级解决方案：

### 方案 A：修改 Windows DNS 服务器（推荐）

1. **打开网络和共享中心**
   - 右键点击网络图标 → 打开"网络和 Internet"设置
   - 选择"更改适配器选项"

2. **修改 DNS 服务器**
   - 右键点击当前使用的网络连接 → 属性
   - 双击"Internet 协议版本 4 (TCP/IPv4)"
   - 选择"使用下面的 DNS 服务器地址"
   - 输入以下公共 DNS：
     ```
     首选 DNS 服务器：8.8.8.8（Google DNS）
     备用 DNS 服务器：8.8.4.4
     ```
     或
     ```
     首选 DNS 服务器：1.1.1.1（Cloudflare DNS）
     备用 DNS 服务器：1.0.0.1
     ```
     或国内用户推荐：
     ```
     首选 DNS 服务器：114.114.114.114
     备用 DNS 服务器：114.114.115.115
     ```
     或阿里云 DNS：
     ```
     首选 DNS 服务器：223.5.5.5
     备用 DNS 服务器：223.6.6.6
     ```

3. **刷新 DNS 缓存**
   ```powershell
   ipconfig /flushdns
   ```

### 方案 B：检查防火墙和网络代理

1. **检查防火墙设置**
   - 确保 Windows 防火墙允许 Java 应用访问外网
   - 如果有第三方杀毒软件，检查其网络保护设置

2. **检查代理设置**
   - 如果使用公司网络或代理，需要在 application.yml 中配置代理：
   ```yaml
   spring:
     ai:
       openai:
         proxy:
           host: your-proxy-host
           port: your-proxy-port
   ```

### 方案 C：测试 DNS 解析

在 PowerShell 中执行以下命令测试：

```powershell
# 测试域名解析
nslookup api.deepseek.com

# 测试网络连接
Test-NetConnection api.deepseek.com -Port 443

# 使用 curl 测试 API 连通性（需要先配置 API Key）
curl.exe -H "Authorization: Bearer YOUR_API_KEY" https://api.deepseek.com/v1/models
```

### 方案 D：临时禁用 IPv6（如果 AAAA 记录查询失败）

DNS 错误中提到 `AAAA` 查询超时，这是 IPv6 的 DNS 记录类型。可以尝试：

1. **禁用 IPv6**
   - 在网络适配器属性中，取消勾选"Internet 协议版本 6 (TCP/IPv6)"
   
2. **或在 application.yml 中强制使用 IPv4**
   ```yaml
   spring:
     ai:
       openai:
         client-options:
           prefer-ipv4: true
   ```

## 验证修复

重启应用后，观察日志：
- 应该看到 "初始化优化的 WebClient 配置" 日志
- 不再出现 DNS 超时错误
- AI 聊天功能正常工作

## 其他注意事项

1. **确认 API Key 配置正确**
   - 检查 `application-secret.yml` 文件中是否配置了有效的 DeepSeek API Key
   - 格式：`spring.ai.openai.api-key: sk-your-api-key`

2. **检查网络连接**
   - 确保您的网络可以访问 https://api.deepseek.com
   - 某些网络环境可能需要科学上网

3. **查看完整错误日志**
   - 如果问题持续，查看完整的异常堆栈信息
   - 关注是否有其他相关的网络错误
