###### SJ-todoList2
# ⭐️ TodoList Project
##### TodoList 앱 만들기(메모 작성 및 수정, 데이터 저장)
##### Project execution period : 2023.08.22~2023.09.01
-----------------------
# 📌 앱 설명

1. 노스토리보드(코드베이스)로 코드 작성
2. 메인 controller
<br/> - 버튼을 통해 TodoViewController
<br/> - AddViewController 로 화면 이동
<br/> - URLSession 통해서 API 호출하여 사진 랜덤으로 보여짐
<br/> - UITapGestureRecognizer 사용하여 imageView 터치시 사진 변경 기능 구현
3. TodoViewController
<br/> - UserDefaults 사용하여 데이터 저장,
<br/> - Header와 Footer로 TableView의 Section 나누기,
<br/> - + 버튼 터치 시 AddViewController 로 이동,
<br/> - Edit 버튼 누를 시 삭제 기능 띄우기,
<br/> - 섹션버튼 터치 시 섹션추가 및 섹션 선택 후 글작성 가능
<br/> - 완료목록에 추가하기 위해 셀 터치시 체크마크 표시 후 색상 변경으로 구분
4. AddViewController
<br/> - 제목 및 내용 작성 후 done 버튼 누를시 0.5 로딩 화면 후 데이터 저장
5. DoneViewController
<br/> - 셀에 체크마크 표시될시 tableViewCell에 추가 

# ● 앱 구성
