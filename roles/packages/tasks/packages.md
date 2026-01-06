# 📦 Packages 설치 (Ansible)
- 서버 초기 세팅에 필요한 **기본 패키지 설치**
- `install_packages` 변수를 통해 **동적 패키지 관리**가 가능
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# Install Packages
# -----------------------------------------------------

# 기본 유틸리티 패키지 설치
- name: "Install base packages"
  apt:
    name: "{{ install_packages }}"
    state: present
    update_cache: yes

# -----------------------------------------------------
# 패키지 설치 검증
# -----------------------------------------------------

- name: "Check installed packages"
  shell: dpkg -l | grep -E "{{ install_packages | replace(',', '|') }}"
  register: packages_check
  changed_when: false

- name: "Assert packages installed"
  assert:
    that:
      - packages_check.rc == 0
    success_msg: "Good!.. | Packages installed successfully"
    fail_msg: "ERROR!.. | Some packages are missing"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ 기본 패키지 설치
- install_packages 변수에 정의된 패키지 목록 설치
- apt 패키지 매니저 사용

예시:
```yaml
# host.ini
install_packages:
  - vim
  - curl
  - wget
  - net-tools
```
---
### 2️⃣ 패키지 설치 검증
- dpkg -l 결과를 기준으로 설치 여부 확인
- 단순 실행 결과가 아닌 실제 패키지 존재 여부 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert packages installed]
ok: [192.168.56.60] => {
    "msg": "Good!.. | Packages installed successfully"
}
~~
```
---
