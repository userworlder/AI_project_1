/**
 * 更新 .docx 文件中的项目名称
 *
 * .docx 文件本质上是 ZIP 压缩包，内部包含 XML 文件。
 * 文本内容存储在 word/document.xml 的 <w:t> 标签中。
 *
 * 使用方法：node update_docx_files.js
 */

const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

// 模拟简单的 ZIP 解包/打包（处理小型 docx 文件）
const LOCAL_FILE_HEADER_SIGNATURE = 0x04034b50;
const CENTRAL_DIR_HEADER_SIGNATURE = 0x02014b50;
const END_OF_CENTRAL_DIR_SIGNATURE = 0x06054b50;

function readUInt32LE(buffer, offset) {
  return buffer.readUInt32LE(offset);
}

function readUInt16LE(buffer, offset) {
  return buffer.readUInt16LE(offset);
}

function findSignature(buffer, signature, startOffset) {
  for (let i = startOffset; i < buffer.length - 4; i++) {
    if (buffer.readUInt32LE(i) === signature) {
      return i;
    }
  }
  return -1;
}

/**
 * 从 ZIP 缓冲区中提取指定文件的内容
 */
function extractFromZip(zipBuffer, targetPath) {
  let offset = 0;
  while (offset < zipBuffer.length) {
    const sig = zipBuffer.readUInt32LE(offset);
    if (sig !== LOCAL_FILE_HEADER_SIGNATURE) break;

    const compressionMethod = readUInt16LE(zipBuffer, offset + 8);
    const compressedSize = readUInt32LE(zipBuffer, offset + 18);
    const uncompressedSize = readUInt32LE(zipBuffer, offset + 22);
    const fileNameLength = readUInt16LE(zipBuffer, offset + 26);
    const extraFieldLength = readUInt16LE(zipBuffer, offset + 28);

    const fileName = zipBuffer.toString('utf8', offset + 30, offset + 30 + fileNameLength);

    const dataStart = offset + 30 + fileNameLength + extraFieldLength;
    let data;

    if (fileName === targetPath) {
      if (compressionMethod === 0) {
        // 未压缩
        data = zipBuffer.slice(dataStart, dataStart + uncompressedSize);
      } else if (compressionMethod === 8) {
        // Deflate 压缩
        const compressed = zipBuffer.slice(dataStart, dataStart + compressedSize);
        data = zlib.inflateRawSync(compressed);
      } else {
        throw new Error(`Unsupported compression method: ${compressionMethod}`);
      }
      return data.toString('utf8');
    }

    offset = dataStart + compressedSize;
  }
  return null;
}

/**
 * 将文件替换到 ZIP 缓冲区中（简化实现 - 只替换小文件）
 * 注意：这是一个简化实现，只处理单文件替换场景
 */
async function replaceInZip(zipBuffer, targetPath, newContent) {
  // 由于实现完整的 ZIP 打包很复杂，
  // 这里使用 Node.js 的 child_process 调用 PowerShell
  const { execSync } = require('child_process');
  const tempDir = path.join(__dirname, '.temp_docx_' + Date.now());

  try {
    // 创建临时目录
    fs.mkdirSync(tempDir, { recursive: true });

    // 写入 zip 文件
    const zipPath = path.join(tempDir, 'input.zip');
    fs.writeFileSync(zipPath, zipBuffer);

    // 使用 PowerShell 解压
    const psExtract = `
      Add-Type -AssemblyName System.IO.Compression.FileSystem
      $zip = [System.IO.Compression.ZipFile]::OpenRead('${zipPath.replace(/\\/g, '\\\\')}')
      $extractDir = '${tempDir.replace(/\\/g, '\\\\')}\\extract'
      [System.IO.Compression.ZipFile]::ExtractToDirectory('${zipPath.replace(/\\/g, '\\\\')}', $extractDir)
      $zip.Dispose()
    `;
    execSync(`powershell -Command "${psExtract.replace(/"/g, '\\"')}"`, { stdio: 'pipe' });

    // 替换文件内容
    const targetFilePath = path.join(tempDir, 'extract', targetPath);
    fs.writeFileSync(targetFilePath, newContent, 'utf8');

    // 使用 PowerShell 重新压缩
    const outputZipPath = path.join(tempDir, 'output.zip');
    const psCompress = `
      Add-Type -AssemblyName System.IO.Compression.FileSystem
      [System.IO.Compression.ZipFile]::CreateFromDirectory('${tempDir.replace(/\\/g, '\\\\')}\\extract', '${outputZipPath.replace(/\\/g, '\\\\')}')
    `;
    execSync(`powershell -Command "${psCompress.replace(/"/g, '\\"')}"`, { stdio: 'pipe' });

    // 读取结果
    const result = fs.readFileSync(outputZipPath);
    return result;
  } finally {
    // 清理临时目录
    if (fs.existsSync(tempDir)) {
      fs.rmSync(tempDir, { recursive: true, force: true });
    }
  }
}

/**
 * 简单替换 XML 文本内容中的字符串
 */
function replaceTextInXml(xmlContent, replacements) {
  // 在 <w:t> 标签中查找并替换文本
  // 注意：docx 中的文本可能会被分割到多个 <w:t> 标签中
  let result = xmlContent;
  for (const [oldStr, newStr] of replacements) {
    // 替换 XML 属性中的内容
    result = result.split(oldStr).join(newStr);
  }
  return result;
}

async function main() {
  console.log('='.repeat(60));
  console.log('灵思·AI学伴 - .docx 文件更新工具');
  console.log('='.repeat(60));

  const files = [
    { src: 'AI伴学平台_项目介绍文档.docx', dst: '灵思AI学伴_项目介绍文档.docx' },
    { src: 'AI伴学平台_接口文档.docx', dst: '灵思AI学伴_接口文档.docx' }
  ];

  const replacements = [
    ['AI伴学平台', '灵思·AI学伴'],
    ['AI 伴学平台', '灵思·AI学伴'],
    ['AI伴学管理后台', '灵思·AI学伴管理后台'],
    ['AI伴学', '灵思·AI学伴'],
  ];

  for (const fileInfo of files) {
    const srcPath = path.join(__dirname, fileInfo.src);
    const dstPath = path.join(__dirname, fileInfo.dst);

    console.log(`\n📄 处理文件: ${fileInfo.src}`);

    if (!fs.existsSync(srcPath)) {
      console.error(`   ❌ 文件不存在: ${srcPath}`);
      continue;
    }

    try {
      // 读取 ZIP 文件
      const zipBuffer = fs.readFileSync(srcPath);

      // 提取 document.xml
      const xmlContent = extractFromZip(zipBuffer, 'word/document.xml');
      if (!xmlContent) {
        console.error('   ❌ 无法从 docx 中提取 word/document.xml');
        continue;
      }

      console.log(`   📝 原始 XML 大小: ${xmlContent.length} 字节`);

      // 替换文本
      const newXml = replaceTextInXml(xmlContent, replacements);

      // 统计替换次数
      let totalReplacements = 0;
      for (const [oldStr] of replacements) {
        const originalCount = (xmlContent.match(new RegExp(oldStr.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g')) || []).length;
        const newCount = (newXml.match(new RegExp(oldStr.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g')) || []).length;
        const replaced = originalCount - newCount;
        if (replaced > 0) {
          console.log(`   ✅ "${oldStr}" → 替换了 ${replaced} 处`);
          totalReplacements += replaced;
        }
      }

      if (totalReplacements === 0) {
        console.log('   ⚠️  没有找到需要替换的文本');
      }

      // 重新打包 ZIP
      const newZipBuffer = await replaceInZip(zipBuffer, 'word/document.xml', newXml);

      // 写入目标文件
      fs.writeFileSync(dstPath, newZipBuffer);
      console.log(`   ✅ 已保存到: ${fileInfo.dst}`);

    } catch (err) {
      console.error(`   ❌ 处理失败: ${err.message}`);
    }
  }

  console.log('\n' + '='.repeat(60));
  console.log('🎉 处理完成！');
  console.log('='.repeat(60));
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
