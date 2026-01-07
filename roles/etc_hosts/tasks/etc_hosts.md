# 🗂 /etc/hosts 생성 및 관리 (Ansible)
- 서버 초기 세팅 시 **/etc/hosts 파일을 인벤토리 기준으로 자동 생성**
- 기존 `/etc/hosts` 파일을 **무조건 덮어쓰기**하여 서버 간 호스트명 통일
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# /etc/hosts 생성 (무조건 덮어쓰기)
# -----------------------------------------------------

- name: "Create /etc/hosts from inventory"
  copy:
    dest: /etc/hosts
    owner: root
    group: root
    mode: '0644'
    content: |
      127.0.0.1   localhost
      ::1         localhost

      {% for host in groups['Ubuntu_Servers'] %}
      {{ hostvars[host]['ansible_host'] }} {{ host }}
      {% endfor %}

# -----------------------------------------------------
# /etc/hosts 설정 검증
# -----------------------------------------------------

- name: "Assert /etc/hosts generated"
  assert:
    that:
      - groups['Ubuntu_Servers'] | length > 0
    success_msg: "Good!.. | /etc/hosts overwritten successfully"
    fail_msg: "ERROR!.. | Ubuntu_Servers group is empty"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ /etc/hosts 파일 생성
- copy 모듈을 사용하여 /etc/hosts 파일 생성
- 기존 파일이 존재하더라도 무조건 덮어쓰기
- localhost, IPv6 localhost 기본 항목 포함
---
### 2️⃣ 인벤토리 기반 호스트 등록
- 인벤토리 그룹 Ubuntu_Servers 기준
- 각 서버의 ansible_host(IP)와 호스트명을 매핑하여 자동 추가
- 모든 서버에서 동일한 /etc/hosts 파일 유지
---
### 3️⃣ 파일 권한 설정
- 소유자: root
- 권한: 0644
- 시스템 기본 보안 정책에 맞게 설정
---
### 4️⃣ /etc/hosts 생성 검증
- Ubuntu_Servers 그룹이 존재하는지 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Assert /etc/hosts generated]
ok: [192.168.56.60] => {
    "msg": "Good!.. | /etc/hosts overwritten successfully"
}
~
```
---
