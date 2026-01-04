# 📦 Packages 설치 (Ansible)

- 서버 초기 세팅에 필요한 **기본 패키지 설치**
- root 계정 패스워드 설정을 함께 수행한다.
- `install_packages` 변수를 통해 **동적 패키지 관리**가 가능하다.

---
<br>

## 🧩 main.yml
```bash
# -----------------------------------------------------
# Root Password & Install Packages
# -----------------------------------------------------

# root 계정 패스워드 설정
- name: "Set Root Password"
  user:
    name: root
    password: "{{ root_password | password_hash('sha512') }}"
    shell: /bin/bash

# 기본 유틸리티 패키지 설치
- name: "Install base packages"
  apt:
    name: "{{ install_packages }}"
    state: present
    update_cache: yes

# 패키지 설치 검증
- name: "Check.. dpkg packages.."
  shell: dpkg -l | grep -E "{{ install_packages | replace(',', '|') }}"
  register: packages_check
  changed_when: false

- name: "Status.. dpkg packages.."
  debug:
    msg: "Good!.. | {{ packages_check.stdout_lines }} installed successfully.."
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Root 계정 패스워드 설정
- Ansible 변수 root_password 값을 사용하여 root 패스워드 설정
- password_hash('sha512') 적용으로 안전하게 암호화
---
### 2️⃣ 기본 패키지 설치
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
### 3️⃣ 패키지 설치 검증
- dpkg -l 결과를 기준으로 설치 여부 확인
- 단순 실행 결과가 아닌 실제 패키지 존재 여부 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Status.. dpkg packages..]
ok: [192.168.56.60] => {
    "msg": "Good!.. | ['ii  vim ...', 'ii  curl ...'] installed successfully.."
}
```
