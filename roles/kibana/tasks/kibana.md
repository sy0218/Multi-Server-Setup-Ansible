# 🔍 Apache Kibana (Ansible)

- Ubuntu 서버에 **Kibana APT 기반 설치**
- **Elastic 공식 저장소 사용**
- 버전 고정 설치 및 설치 검증 포함
- Elasticsearch 호스트 여러 개 연결 가능

---
<br>

## 🧩 main.yml
```yaml
# -----------------------------------------------------
# 1. Elasticsearch GPG Key 등록 (공유)
# -----------------------------------------------------
- name: "Add Elasticsearch GPG key"
  apt_key:
    url: https://artifacts.elastic.co/GPG-KEY-elasticsearch
    state: present

# -----------------------------------------------------
# 2. Elasticsearch APT repository 추가 (공유)
# -----------------------------------------------------
- name: "Add Elasticsearch APT repository"
  apt_repository:
    repo: "deb https://artifacts.elastic.co/packages/{{ kibana_version.split('.')[0] }}.x/apt stable main"
    state: present
    filename: "elastic-{{ kibana_version.split('.')[0] }}.x"
  register: elastic_repo

# -----------------------------------------------------
# 3. APT cache 업데이트 (repo 변경 시)
# -----------------------------------------------------
- name: "Update apt cache if repo changed"
  apt:
    update_cache: yes
  when: elastic_repo.changed

# -----------------------------------------------------
# 4. Kibana 설치
# -----------------------------------------------------
- name: "Install Kibana {{ kibana_version }}"
  apt:
    name: "kibana={{ kibana_version }}"
    state: present

# -----------------------------------------------------
# 5. Kibana 설정 (/etc/kibana/kibana.yml)
# -----------------------------------------------------
- name: "Configure Kibana server host"
  lineinfile:
    path: /etc/kibana/kibana.yml
    regexp: '^server.host:'
    line: 'server.host: "0.0.0.0"'
    create: yes

- name: "Set Elasticsearch URLs in Kibana config"
  lineinfile:
    path: /etc/kibana/kibana.yml
    regexp: '^elasticsearch.hosts:'
    line: 'elasticsearch.hosts: [{{ elasticsearch_hosts.split(",") | map("quote") | join(", ") }}]'
    create: yes

# -----------------------------------------------------
# 6. Kibana 서비스 활성화 및 시작
# -----------------------------------------------------
- name: "Enable and start Kibana service"
  systemd:
    name: kibana
    enabled: yes
    state: started

# -----------------------------------------------------
# 7. Kibana 설치 검증
# -----------------------------------------------------
- name: "Get Kibana version"
  command: /usr/share/kibana/bin/kibana --version --allow-root
  register: kibana_version_check
  changed_when: false
  failed_when: false

- name: "Verify Kibana installation"
  assert:
    that:
      - "'{{ kibana_version }}' in kibana_version_check.stdout"
    success_msg: "Good!.. | Kibana {{ kibana_version }} installed successfully"
    fail_msg: "ERROR!.. | Kibana version mismatch or not installed"
```
---
<br>

## 🛠 작업 내용
### 1️⃣ Elasticsearch GPG Key 등록
- Elastic 공식 패키지 서명 검증을 위한 GPG Key 등록
- APT 패키지 무결성 보장
---
### 2️⃣ Elasticsearch APT Repository 추가
- elasticsearch_version 기준으로 메이저 버전(x) 저장소 사용
- 예: 8.12.2 → 8.x
- /etc/apt/sources.list.d/elastic-8.x.list 파일 생성
---
### 3️⃣ APT Cache 업데이트
- Repository 변경이 발생한 경우에만 apt update 수행
- 불필요한 캐시 갱신 방지 (멱등성 유지)
---
### 4️⃣ Kibana 설치
- 특정 버전(1kibana_version1)으로 패키지 설치
- 버전 고정 설치로 운영 환경 안정성 확보
---
### 5️⃣ Kibana 설정
- `server.host: 0.0.0.0` → 모든 인터페이스에서 접근 가능
- `elasticsearch.hosts: [...]` → 다중 ES 노드 연결 가능
- Jinja2 `split | map("quote") | join(", ")` 사용 → 안전하게 여러 호스트 처리
---
### 6️⃣ Kibana 서비스 활성화 및 시작
- systemd에서 자동 시작
- 즉시 서비스 시작
---
### 7️⃣ Kibana 설치 검증
- `kibana --version --allow-root` 실행 (root 사용자도 assert 가능)
- 설치 버전과 기대 버전 불일치 시 Ansible assert 실패 처리
---
<br>

## ✅ 실행 결과 예시
```bash
TASK [Verify Kibana installation]
ok: [apserver] => {
    "msg": "Good!.. | Kibana 8.4.2 installed successfully"
}
~
```
---
