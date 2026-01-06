# 📦 패키지 버전 고정 (Kernel & Java)

- 커널(Kernel) 및 Java 패키지의 버전을 고정하여  자동 업그레이드로 인한 장애를 방지한다.
- `apt-mark hold` 기반으로 패키지 업그레이드를 차단한다.
- Java 버전은 변수(`java_version`) 기반으로 동적 제어한다.

---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# 패키지 버전 고정
# -----------------------------------------------------

# 커널 버전 수집
- name: "Get kernel version"
  command: uname -r
  register: kernel_version
  changed_when: false

# 커널 및 Java 패키지 hold
- name: "Hold kernel and Java packages"
  command: >
    apt-mark hold
    linux-image-{{ kernel_version.stdout }}
    openjdk-{{ java_version }}-jdk
    openjdk-{{ java_version }}-jdk-headless
    openjdk-{{ java_version }}-jre
    openjdk-{{ java_version }}-jre-headless
  args:
    warn: false
  changed_when: false

# -----------------------------------------------------
# 패키지 버전 고정 검증
# -----------------------------------------------------

- name: "Check held packages"
  command: apt-mark showhold
  register: held_packages
  changed_when: false

- name: "Assert kernel and Java packages are held"
  assert:
    that:
      - "'linux-image-{{ kernel_version.stdout }}' in held_packages.stdout"
      - "'openjdk-{{ java_version }}-jdk' in held_packages.stdout"
      - "'openjdk-{{ java_version }}-jdk-headless' in held_packages.stdout"
      - "'openjdk-{{ java_version }}-jre' in held_packages.stdout"
      - "'openjdk-{{ java_version }}-jre-headless' in held_packages.stdout"
    success_msg: "Good!.. | Kernel & Java {{ java_version }} packages are held successfully"
    fail_msg: "ERROR!.. | Kernel or Java {{ java_version }} packages are NOT held"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ 커널 버전 자동 수집
- `uname -r` 명령어를 사용하여 현재 실행 중인 커널 버전을 수집
---
### 2️⃣ 커널 및 Java 패키지 버전 고정
- `apt-mark hold` 명령어로 다음 패키지들의 자동 업데이트 차단
- 현재 커널 이미지 패키지
- OpenJDK (지정된 Java 버전)
 ---
### 3️⃣ 설정 검증
- `apt-mark showhold` 결과를 기반으로
- 커널 및 Java 패키지가 정상적으로 hold 되었는지 검증
---
<br>

## 🧩 변수 설명
```ini
# host.ini
[Ubuntu_Servers:vars]
java_version=11
```
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert kernel and Java packages are held]
ok: [192.168.56.60] => {
    "msg": "Good!.. | Kernel & Java 11 packages are held successfully"
}
~
```
---
