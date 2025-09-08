# 🤝 Katkıda Bulunma Rehberi

TurfaLearn projesine katkıda bulunmak istediğiniz için teşekkür ederiz! Bu rehber, projeye nasıl katkı sağlayabileceğinizi açıklamaktadır.

## 📋 İçindekiler

1. [Davranış Kuralları](#davranış-kuralları)
2. [Katkı Türleri](#katkı-türleri)
3. [Geliştirme Süreci](#geliştirme-süreci)
4. [Kod Standartları](#kod-standartları)
5. [Pull Request Süreci](#pull-request-süreci)
6. [Issue Rehberi](#issue-rehberi)
7. [Geliştirme Ortamı](#geliştirme-ortamı)
8. [Test Süreci](#test-süreci)
9. [Dokümantasyon](#dokümantasyon)
10. [İletişim](#iletişim)

---

## 🤝 Davranış Kuralları

### Bizim Taahhüdümüz

Açık ve misafirperver bir ortam yaratmak amacıyla, katkıda bulunanlar ve sürdürücüler olarak, yaş, vücut ölçüsü, engellilik, etnik köken, cinsel kimlik ve ifade, deneyim seviyesi, milliyet, kişisel görünüş, ırk, din veya cinsel kimlik ve yönelim fark etmeksizin, projemize ve topluluğumuza katılımı herkes için taciz içermeyen bir deneyim haline getirmeyi taahhüt ediyoruz.

### Standartlarımız

#### ✅ Olumlu davranış örnekleri:
- Empati ve nezaket göstermek
- Farklı görüş ve deneyimlere saygı duymak
- Yapıcı eleştiri vermek ve kabul etmek
- Topluluk için en iyisine odaklanmak
- Diğer topluluk üyelerine karşı empati göstermek

#### ❌ Kabul edilemez davranış örnekleri:
- Cinselleştirilmiş dil veya görüntü kullanımı
- Trolleme, hakaret/aşağılayıcı yorumlar ve kişisel/politik saldırılar
- Kamu veya özel taciz
- Başkalarının özel bilgilerini izin olmadan yayımlamak
- Profesyonel bir ortamda mantıklı olarak uygunsuz sayılabilecek diğer davranışlar

---

## 🎯 Katkı Türleri

### 🐛 Bug Raporları
- Hatalar ve sorunları bildirin
- Yeniden üretme adımlarını sağlayın
- Ekran görüntüleri ekleyin

### ✨ Özellik Önerileri
- Yeni özellikler önerin
- Kullanım senaryoları açıklayın
- Mockup'lar veya tasarım önerileri paylaşın

### 📝 Dokümantasyon
- README ve diğer dokümanları geliştirin
- Çeviri sağlayın
- Örnekler ve rehberler ekleyin

### 🔧 Kod Katkıları
- Bug düzeltmeleri
- Yeni özellik implementasyonları
- Performans iyileştirmeleri
- Test coverage artışı

### 🎨 Tasarım ve UX
- UI/UX iyileştirmeleri
- Tema ve stil düzenlemeleri
- Görsel varlık katkıları

---

## 🔄 Geliştirme Süreci

### 1. **Fork ve Clone**

```bash
# GitHub'da repository'yi fork edin
# Sonra local'inize klonlayın
git clone https://github.com/YOUR-USERNAME/moodle-render.git
cd moodle-render

# Upstream repository'yi ekleyin
git remote add upstream https://github.com/umur957/moodle-render.git
```

### 2. **Branch Oluşturma**

```bash
# Ana branch'i güncel tutun
git checkout main
git pull upstream main

# Yeni branch oluşturun
git checkout -b feature/amazing-feature
# veya
git checkout -b bugfix/issue-123
# veya  
git checkout -b docs/improve-readme
```

#### Branch İsimlendirme Kuralları:
- `feature/feature-name` - Yeni özellikler için
- `bugfix/issue-number` - Bug düzeltmeleri için
- `docs/topic` - Dokümantasyon güncellemeleri için
- `refactor/component-name` - Kod refactor için
- `test/test-description` - Test eklemeleri için

### 3. **Geliştirme**

```bash
# Değişikliklerinizi yapın
# Test edin
# Commit edin (aşağıdaki standartlara uygun)
```

### 4. **Commit ve Push**

```bash
# Değişiklikleri staging area'ya ekleyin
git add .

# Conventional Commits formatında commit edin
git commit -m "feat: add BigBlueButton integration dashboard"

# Branch'inizi push edin
git push origin feature/amazing-feature
```

---

## 📏 Kod Standartları

### 🏷️ Commit Message Formatı

[Conventional Commits](https://conventionalcommits.org/) standardını kullanıyoruz:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Commit Türleri:
- `feat`: Yeni özellik
- `fix`: Bug düzeltmesi  
- `docs`: Dokümantasyon değişiklikleri
- `style`: Kod anlamını etkilemeyen değişiklikler (beyaz boşluk, biçimlendirme)
- `refactor`: Ne bug düzeltmesi ne de özellik ekleyen kod değişikliği
- `perf`: Performans iyileştiren kod değişikliği
- `test`: Eksik testleri eklemek veya mevcut testleri düzeltmek
- `chore`: Build sürecine veya yardımcı araçlara yapılan değişiklikler

#### Örnekler:
```bash
feat: add Examus integration for online proctoring
fix: resolve Docker container startup issues
docs: update installation guide with SSL configuration
style: format docker-compose.yml file
refactor: improve Moodle configuration structure
perf: optimize MariaDB query performance
test: add integration tests for BigBlueButton
chore: update Docker base image to latest version
```

### 🎨 Kod Stili

#### Docker ve YAML Dosyaları:
```yaml
# Doğru indentasyon (2 boşluk)
version: '3'
services:
  moodle:
    image: bitnami/moodle:latest
    environment:
      - MOODLE_USERNAME=admin
      - MOODLE_PASSWORD=secure_password
```

#### Shell Scripts:
```bash
#!/bin/bash

# Değişkenleri BÜYÜK HARF ile tanımlayın
BACKUP_DIR="/opt/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Fonksiyonları tanımlayın
backup_database() {
    echo "🔄 Veritabanı yedeği alınıyor..."
    # Implementation
}

# Main logic
main() {
    backup_database
    echo "✅ Yedekleme tamamlandı"
}

main "$@"
```

#### Markdown Dosyaları:
```markdown
# H1 için # kullanın (her dosyada sadece bir tane)

## H2 için ## kullanın

### H3 için ### kullanın

- Liste öğeleri için - kullanın
- **Kalın metin** için **text**
- *İtalik metin* için *text*
- `Kod` için backtick kullanın

```code block
Kod blokları için üç backtick
```

#### JSON Dosyaları:
```json
{
  "name": "TurfaLearn",
  "version": "2.0.0",
  "description": "Comprehensive Moodle LMS Docker deployment",
  "keywords": [
    "moodle",
    "lms",
    "docker",
    "education"
  ]
}
```

---

## 📬 Pull Request Süreci

### 1. **PR Oluşturmadan Önce**

#### ✅ Checklist:
- [ ] Branch güncel (`git pull upstream main`)
- [ ] Tüm testler geçiyor
- [ ] Kod standartlarına uygun
- [ ] Dokümantasyon güncellenmiş
- [ ] CHANGELOG.md güncellendi (eğer gerekiyorsa)
- [ ] Conventional Commits formatı kullanıldı

### 2. **PR Template**

Pull Request oluştururken şu template'i kullanın:

```markdown
## 📝 Değişiklik Özeti
<!-- Kısa ve net açıklama -->

## 🎯 Değişiklik Türü
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📝 This change requires a documentation update

## 🧪 Test Edildi mi?
- [ ] Evet, local ortamda test edildi
- [ ] Unit testler yazıldı/güncellendi
- [ ] Integration testler yazıldı/güncellendi
- [ ] Manual test yapıldı

## 📸 Ekran Görüntüleri (eğer UI değişikliği varsa)
<!-- Before/After screenshots -->

## 📋 Checklist:
- [ ] Kod kendi kendini açıklıyor veya yorum eklendi
- [ ] Yeni testler eklendi (eğer uygulanabilirse)
- [ ] Mevcut testlerin hepsi geçiyor
- [ ] Documentation güncellendi
- [ ] CHANGELOG.md güncellendi
```

### 3. **Code Review Süreci**

#### Review Kriterleri:
- ✅ Kod kalitesi ve okunabilirlik
- ✅ Test coverage
- ✅ Performance impact
- ✅ Security considerations  
- ✅ Documentation completeness
- ✅ Backward compatibility

#### Review Sürecinde:
1. **Draft PR** oluşturun (work-in-progress için)
2. **Ready for Review** olarak işaretleyin
3. **Reviewer feedback**'ine yanıt verin
4. **Requested changes**'i yapın
5. **Re-review** isteyin

---

## 🐛 Issue Rehberi

### Bug Report Template

```markdown
---
name: 🐛 Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## 🐛 Bug Tanımı
Kısa ve net bug açıklaması.

## 🔄 Yeniden Üretme Adımları
1. Git to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## ✅ Beklenen Davranış
Neyin olmasını bekliyordunuz?

## 📸 Ekran Görüntüleri
Mümkünse screenshot ekleyin.

## 🖥️ Ortam Bilgileri:
- OS: [e.g. Ubuntu 24.04]
- Docker Version: [e.g. 24.0.7]
- Docker Compose Version: [e.g. 2.21.0]
- Browser: [e.g. chrome, safari]

## 📝 Ek Bilgiler
Ek context veya açıklamalar.
```

### Feature Request Template

```markdown
---
name: ✨ Feature Request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

## 🚀 Özellik Açıklaması
Özelliğin net açıklaması.

## 💡 Motivasyon
Bu özellik hangi sorunu çözüyor? Alternatifleri denediniz mi?

## 📝 Detaylı Açıklama
Özelliğin nasıl çalışmasını istiyorsunuz?

## 🎨 Mockups/Examples
Varsa tasarım veya örnek paylaşın.

## 📋 Acceptance Criteria
- [ ] Criteria 1
- [ ] Criteria 2
- [ ] Criteria 3

## ⚡ Priority
- [ ] High
- [ ] Medium
- [ ] Low
```

---

## 🔧 Geliştirme Ortamı

### Sistem Gereksinimleri

#### Minimum:
- **OS**: Ubuntu 20.04+ / macOS 11+ / Windows 10 WSL2
- **Docker**: 20.10+
- **Docker Compose**: v2.0+
- **Git**: 2.30+
- **Node.js**: 16+ (dokümantasyon için)

#### Önerilen:
- **RAM**: 8GB+
- **Storage**: 50GB+ SSD
- **CPU**: 4+ cores

### Development Setup

```bash
# 1. Repository'yi klonlayın
git clone https://github.com/umur957/moodle-render.git
cd moodle-render

# 2. Pre-commit hooks kurun (opsiyonel)
npm install -g @commitlint/cli @commitlint/config-conventional
npm install -g husky

# 3. Development ortamını başlatın
docker-compose up -d

# 4. Logları takip edin
docker-compose logs -f moodle
```

### IDE Ayarları

#### Visual Studio Code Önerilen Extensions:
```json
{
  "recommendations": [
    "ms-azuretools.vscode-docker",
    "redhat.vscode-yaml", 
    "ms-vscode.vscode-json",
    "davidanson.vscode-markdownlint",
    "timonwong.shellcheck",
    "formulahendry.auto-rename-tag"
  ]
}
```

#### Settings:
```json
{
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "yaml.format.enable": true,
  "docker.languageserver.formatter.ignoreMultilineInstructions": true
}
```

---

## 🧪 Test Süreci

### Test Türleri

#### 1. **Unit Tests**
```bash
# Container içindeki Moodle'da unit test çalıştırma
docker exec moodle-render_moodle_1 php admin/tool/phpunit/cli/util.php --install
docker exec moodle-render_moodle_1 php admin/tool/phpunit/cli/util.php --buildconfig
docker exec moodle-render_moodle_1 vendor/bin/phpunit
```

#### 2. **Integration Tests**
```bash
# Docker servislerinin entegrasyonunu test etme
./scripts/integration-test.sh
```

#### 3. **End-to-End Tests**
```bash
# Tarayıcı tabanlı testler (Selenium)
./scripts/e2e-test.sh
```

#### 4. **Performance Tests**
```bash
# Load testing with Apache Bench
ab -n 100 -c 10 http://localhost:8080/login/index.php
```

### Test Yazma Rehberi

#### Test Dosya Yapısı:
```
tests/
├── unit/
│   ├── ConfigTest.php
│   └── DatabaseTest.php
├── integration/
│   ├── DockerComposeTest.php
│   └── MoodleStartupTest.php
└── e2e/
    ├── LoginTest.js
    └── CourseCreationTest.js
```

#### Test Örnekleri:

**PHP Unit Test:**
```php
<?php
class ConfigTest extends PHPUnit\Framework\TestCase
{
    public function testMoodleConfigExists()
    {
        $configFile = '/opt/bitnami/moodle/config.php';
        $this->assertFileExists($configFile);
    }
    
    public function testDatabaseConnection()
    {
        // Test database connectivity
        $this->assertTrue($this->canConnectToDatabase());
    }
}
```

**Integration Test (Bash):**
```bash
#!/bin/bash
# integration-test.sh

# Test Docker containers are running
test_containers_running() {
    if ! docker-compose ps | grep -q "Up"; then
        echo "❌ Containers not running"
        return 1
    fi
    echo "✅ Containers are running"
}

# Test Moodle is accessible
test_moodle_accessible() {
    if ! curl -f -s http://localhost:8080/login/index.php > /dev/null; then
        echo "❌ Moodle not accessible"
        return 1
    fi
    echo "✅ Moodle is accessible"
}

# Run all tests
main() {
    test_containers_running || exit 1
    test_moodle_accessible || exit 1
    echo "🎉 All integration tests passed!"
}

main "$@"
```

---

## 📚 Dokümantasyon

### Dokümantasyon Türleri

#### 1. **Teknik Dokümantasyon**
- API referansları
- Konfigürasyon rehberleri
- Troubleshooting guides

#### 2. **Kullanıcı Dokümantasyonu**
- Kurulum kılavuzları
- Kullanım örnekleri
- FAQ

#### 3. **Geliştirici Dokümantasyonu**
- Mimari açıklamaları
- Katkıda bulunma rehberleri
- Code style guides

### Dokümantasyon Standardları

#### Markdown Formatı:
```markdown
# Ana Başlık (sadece bir tane)

## Alt Başlıklar

### Daha Alt Başlıklar

- Liste öğeleri
  - Alt liste
  - Alt liste

1. Numaralı liste
2. İkinci öğe

**Kalın metin**
*İtalik metin*
`Kod parçacığı`

```kod bloğu
echo "Merhaba Dünya"
```

> Alıntı bloğu
> Çok satırlı alıntı

[Link metni](https://example.com)
![Resim alt metni](image.png)
```

#### Tablo Formatı:
```markdown
| Kolon 1 | Kolon 2 | Kolon 3 |
|---------|---------|---------|
| Değer 1 | Değer 2 | Değer 3 |
| Değer 4 | Değer 5 | Değer 6 |
```

### Dokümantasyon Review Süreci

1. **Yazmadan önce**: Hedef kitleyi belirleyin
2. **Yazım sırasında**: Net ve basit dil kullanın
3. **Yazdıktan sonra**: Başka biri tarafından review ettirin
4. **Güncel tutma**: Kod değiştiğinde dokümantasyonu da güncelleyin

---

## 🎨 Tasarım Katkıları

### UI/UX Guidelines

#### Renk Paleti:
```css
:root {
  --primary-color: #FF6600;    /* Moodle Orange */
  --secondary-color: #0066CC;  /* Moodle Blue */
  --success-color: #28a745;    /* Success Green */
  --danger-color: #dc3545;     /* Error Red */
  --warning-color: #ffc107;    /* Warning Yellow */
  --info-color: #17a2b8;       /* Info Cyan */
  --dark-color: #343a40;       /* Dark Gray */
  --light-color: #f8f9fa;      /* Light Gray */
}
```

#### Typography:
```css
/* Heading Hierarchy */
h1 { font-size: 2.5rem; font-weight: 700; }
h2 { font-size: 2rem; font-weight: 600; }
h3 { font-size: 1.75rem; font-weight: 600; }
h4 { font-size: 1.5rem; font-weight: 500; }

/* Body Text */
body { font-size: 1rem; line-height: 1.6; }
.lead { font-size: 1.25rem; font-weight: 300; }
```

### Icon Usage

Proje genelinde tutarlı icon kullanımı:
- 📚 Eğitim/Kurs içerikleri için
- 🔒 Güvenlik özellikleri için  
- 🌐 Ağ/Web servisleri için
- ⚡ Performans ile ilgili için
- 🛠️ Araçlar ve yönetim için

---

## 📞 İletişim

### Proje Maintainers

- **Umur Kizildas** ([@umur957](https://github.com/umur957))
  - 📧 Email: info@tuerfa.de
  - 🌐 Website: [www.tuerfa.de](http://www.tuerfa.de)
  - 📱 Telefon: +90 0533 924 3850

### İletişim Kanalları

#### GitHub Issues
- **Bug Reports**: [Issues sayfası](https://github.com/umur957/moodle-render/issues)
- **Feature Requests**: [New Issue](https://github.com/umur957/moodle-render/issues/new)
- **Questions**: [Q&A Discussions](https://github.com/umur957/moodle-render/discussions)

#### Email
- **Genel Sorular**: info@tuerfa.de
- **Güvenlik Sorunları**: security@tuerfa.de
- **Partnershiper**: partners@tuerfa.de

### Response Times

| Konu | Response Süresi |
|------|----------------|
| 🚨 **Critical Bugs** | 24 saat içinde |
| 🐛 **Regular Bugs** | 3-5 iş günü |
| ✨ **Feature Requests** | 1-2 hafta |
| ❓ **Questions** | 2-3 iş günü |
| 📝 **Documentation** | 1 hafta |

---

## 📄 Lisans

Bu projeye katkıda bulunarak, katkılarınızın [MIT Lisansı](./LICENSE) altında lisanslanacağını kabul etmiş olursunuz.

---

## 🎉 Katkıda Bulunanlar

Tüm katkıda bulunanlara teşekkür ederiz! 

<!-- ALL-CONTRIBUTORS-LIST:START -->
<!-- Katkıda bulunanlar listesi buraya otomatik olarak eklenecek -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

---

## 💝 Sponsorluk

TurfaLearn projesini desteklemek istiyorsanız:

- ⭐ **GitHub'da star** verin
- 🐛 **Bug report** edin
- 📝 **Dokümantasyon** iyileştirin
- 💰 **Sponsorluk** yapmayı düşünün

---

*Bu rehber sürekli güncellenmektedir. Önerileriniz için [issue açabilir](https://github.com/umur957/moodle-render/issues) veya doğrudan [email](mailto:info@tuerfa.de) gönderebilirsiniz.*

*© 2025 Turfa GbR. Tüm hakları saklıdır. • Made with ❤️ in Germany & Turkey*