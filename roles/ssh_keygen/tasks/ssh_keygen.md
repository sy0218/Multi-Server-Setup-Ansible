# 🔐 SSH Key 생성 및 상호 공유 (Ansible)
- 서버 초기 세팅 시 **모든 서버 간 SSH 무비밀번호 접속 구성**
- 각 서버에서 SSH Key를 생성하고, 모든 서버의 공개키를 상호 교환하여 `authorized_keys`에 등록
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 모든 서버 SSH Key 생성 및 상호 공유
# -----------------------------------------------------

# SSH 키 쌍 생성
- name: "Create 4096-bit RSA key pair"
  openssh_keypair:
    path: /root/.ssh/id_rsa
    type: rsa
    size: 4096
    owner: root
    group: root
    mode: '0600'
    force: no
  register: ssh_key

# 공개키를 host fact로 저장
- name: "Save public key as host fact"
  set_fact:
    my_public_key: "{{ ssh_key.public_key }}"

# 모든 서버 공개키를 리스트로 수집
- name: "Collect all server public keys"
  set_fact:
    all_public_keys: >-
      {{
        groups['Ubuntu_Servers']
        | map('extract', hostvars, 'my_public_key')
        | list
      }}

# authorized_keys에 모든 서버 공개키 배포
- name: "Distribute all server public keys"
  authorized_key:
    user: root
    key: "{{ item }}"
    state: present
  loop: "{{ all_public_keys }}"

# authorized_keys 권한 보정
- name: "Ensure authorized_keys permission"
  file:
    path: /root/.ssh/authorized_keys
    owner: root
    group: root
    mode: '0600'

# -----------------------------------------------------
# ssh_keygen 검증
# -----------------------------------------------------

# 공개키가 authorized_keys에 있는지 검증
- name: "Verify SSH key authorization"
  assert:
    that:
      - my_public_key in lookup('file', '/root/.ssh/authorized_keys')
    success_msg: "Good!.. | SSH key exchange completed"
    fail_msg: "ERROR!.. | SSH key exchange FAILED"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ SSH 키 쌍 생성
- openssh_keypair 모듈을 사용하여 4096-bit RSA 키 생성
- 기존 키가 존재할 경우 force: no로 재생성 방지
- /root/.ssh/id_rsa 경로에 키 생성
---
### 2️⃣ 공개키 Fact 저장
- 생성된 공개키를 my_public_key 변수로 저장
- 이후 서버 간 공개키 수집에 사용
---
### 3️⃣ 모든 서버 공개키 수집
- 인벤토리 그룹 Ubuntu_Servers 기준
- hostvars를 사용하여 모든 서버의 공개키를 리스트로 취합
---
### 4️⃣ 공개키 상호 배포
- 모든 서버의 공개키를 각 서버의 authorized_keys에 등록
- 결과적으로 모든 서버 ↔ 모든 서버 간 SSH 무비밀번호 접속 가능
---
### 5️⃣ authorized_keys 권한 보정
- 보안 강화를 위해 파일 권한을 0600으로 설정
---
### 6️⃣ SSH 키 교환 검증
- 현재 서버의 공개키가 authorized_keys에 포함되어 있는지 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Verify SSH key authorization]
ok: [192.168.56.60] => {
    "msg": "Good!.. | SSH key exchange completed"
}
~~
```
---
