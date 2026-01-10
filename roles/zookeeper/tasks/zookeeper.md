# ⚙️ Apache ZooKeeper 설치 및 기본 설정 (Ansible)
- Ubuntu 서버에 **Apache ZooKeeper 바이너리 설치**
- **지정된 디렉토리 구조로 설치 및 심볼릭 링크 구성**
- **클러스터 구성 필수 요소(myid) 설정 및 검증 포함**
---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. ZooKeeper 설치 디렉토리 생성
# -----------------------------------------------------
- name: "Create ZooKeeper base directory"
  file:
    path: "{{ zookeeper_install_dir }}"
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 2. ZooKeeper 다운로드
# -----------------------------------------------------
- name: "Download ZooKeeper"
  get_url:
    url: "{{ zookeeper_url }}"
    dest: "/tmp/{{ zookeeper_url | basename }}"
    mode: '0644'

# -----------------------------------------------------
# 3. ZooKeeper 압축 해제
# -----------------------------------------------------
- name: "Extract ZooKeeper"
  unarchive:
    src: "/tmp/{{ zookeeper_url | basename }}"
    dest: "{{ zookeeper_install_dir }}"
    remote_src: yes
    creates: "{{ zookeeper_install_dir }}/{{ (zookeeper_url | basename) | regex_replace('.tar.gz','') }}"

# -----------------------------------------------------
# 4. ZooKeeper 심볼릭 링크 생성
# -----------------------------------------------------
- name: "Create ZooKeeper symlink"
  file:
    src: "{{ zookeeper_install_dir }}/{{ (zookeeper_url | basename) | regex_replace('.tar.gz','') }}"
    dest: "{{ zookeeper_install_dir }}/zookeeper"
    state: link
    force: yes

# -----------------------------------------------------
# 5. ZooKeeper 데이터 디렉토리 생성
# -----------------------------------------------------
- name: "Create ZooKeeper data directory"
  file:
    path: "{{ zookeeper_data_dir }}"
    state: directory
    owner: root
    group: root
    mode: '0755'

# -----------------------------------------------------
# 6. myid 설정
# -----------------------------------------------------
- name: "Set ZooKeeper myid"
  copy:
    dest: "{{ zookeeper_data_dir }}/myid"
    content: "{{ zookeeper_myid }}\n"
    owner: root
    group: root
    mode: '0644'

# -----------------------------------------------------
# 7. ZooKeeper 설치 검증
# -----------------------------------------------------
- name: "Check ZooKeeper binary existence"
  stat:
    path: "{{ zookeeper_install_dir }}/zookeeper/bin/zkServer.sh"
  register: zk_bin_check

- name: "Verify ZooKeeper Installation"
  assert:
    that:
      - zk_bin_check.stat.exists
    fail_msg: "ZooKeeper binary not found at {{ zookeeper_install_dir }}/zookeeper/bin/zkServer.sh. Please check extraction or symlink."
    success_msg: "ZooKeeper installation verified: Binary exists at the expected path."

# -----------------------------------------------------
# 8. myid 설정 검증
# -----------------------------------------------------
- name: "Read myid file content"
  slurp:
    src: "{{ zookeeper_data_dir }}/myid"
  register: myid_content

- name: "Verify ZooKeeper myid content"
  assert:
    that:
      - "myid_content['content'] | b64decode | trim == zookeeper_myid | string"
    fail_msg: "myid mismatch! Expected: {{ zookeeper_myid }}, Found: {{ myid_content['content'] | b64decode | trim }}"
    success_msg: "ZooKeeper myid validation passed: ID is correctly set to {{ zookeeper_myid }}."
```
---
<br>

## 🛠 작업 내용
### 1️⃣ ZooKeeper 설치 디렉토리 생성
- ZooKeeper 바이너리 설치를 위한 기본 경로 생성
---
### 2️⃣ ZooKeeper 바이너리 다운로드
- zookeeper_url 변수 기반 tar.gz 파일 다운로드
- /tmp 디렉토리에 저장
---
### 3️⃣ ZooKeeper 압축 해제
- 원격 서버에서 직접 압축 해제
- creates 옵션으로 멱등성 보장
---
### 4️⃣ ZooKeeper 심볼릭 링크 구성
- 버전 디렉토리 → zookeeper 심볼릭 링크 생성
---
### 5️⃣ ZooKeeper 데이터 디렉토리 생성
- ZooKeeper 데이터 저장 경로 생성
- myid 및 snapshot, log 저장 위치
---
### 6️⃣ myid 설정
- 클러스터 노드 식별용 myid 파일 생성
- 각 서버별 고유 ID 값 사용
---
### 7️⃣ ZooKeeper 설치 검증
- zkServer.sh 바이너리 존재 여부 확인
- 설치 및 심볼릭 링크 정상 여부 검증
---
### 8️⃣ myid 설정 검증
- myid 파일 실제 내용 slurp 후 base64 decode
- 기대값과 일치 여부 assert로 검증
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Verify ZooKeeper Installation]
ok: [apserver] => {
    "msg": "ZooKeeper installation verified: Binary exists at the expected path."
}

TASK [Verify ZooKeeper myid content]
ok: [apserver] => {
    "msg": "ZooKeeper myid validation passed: ID is correctly set to 1."
}
~
```
---
