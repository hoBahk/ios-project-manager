# 📌 프로젝트 관리 앱

- 프로젝트 기간: 2022.02.28 ~ 2022.03.11

<br>

## 키워드
- `LocalDB`
    - `Realm`, `SQLite`, `CoreData`
- `RemoteDB`
    - `Firebase`, `CloudKit`
- `SPM (Swift Package Manager)`
- `SwiftUI`
	- `@EnvironmentObject`, `@State`, `@Binding`
	- `Text`, `Button`, `DatePicker`, `TextField`, `TextEditor`, `List`
	- `HStack`, `VStack`
	- `onTapGesture`, `onLongPressGesture`
	- `sheet`, `popover`
- `MVVM`
	- `ViewModel`


<br>

## 구현 내용
- Realm, Firebase를 연동하여 데이터를 관리
-  MVVM 패턴으로 설계 하여 구현
-  SwiftUI를 사용하여 뷰를 구현
- 뷰를 적절히 분리하여 빌드의 부담을 줄이고 가독성을 높힘
- Todo/Doing/Done의 상태를 이용하여 각 해당 List에 맞게 구현하였다.
- HStack 안에 List 세개를 나란히 위치시켜 구현
- popover, sheet에 대해서 학습하고 사용
- 한 번 터치, 길게 누르는 터치에 따른 액션을 정의
-  업무의 진행상태를 enum으로 효율적으로 관리
- 의존성 관리도구에 대해 학습하고 SPM을 사용하여 진행

<br>

# STEP1 프로젝트 적용기술 선정

## 고민한 점

### 1. LocalDB 비교   

|종류|Realm|SQLite|Core Data|   
|---|-----|------|---------|   
|특징| - 오픈 소스 라이브러리로 모바일에 최적화된 데이터베이스 라이브러리 </br> - 데이터 컨테이너 모델을 사용하며 데이터 객체는 Realm에 객체로 저장 (객체중심의 데이터베이스) </br>- 메인쓰레드에서 데이터 읽기/쓰기 가능| - 전세계적으로 가장 많이 사용 되는 데이터 베이스 엔진이며 오픈소스 </br>- 서버가 필요없는 SQL 데이터 베이스 엔진 </br>- Swift에서는 특별한 설치 없이 바로 사용| - iOS에서 자체 제공하기 때문에 비교적 안정적임 </br>- Object에 더 중심을 둠 </br>- Obejct-C에 클래스로 표현되는 객체의 내용을 저장|
|장점| - 복잡한 Entity에 대한 매핑을 처리해야할 문제가 없으므로 Realm은 메모리 상의 객체를 디스크로 빠르게 가져올 수 있음 <br>- 데이터 용량에 제한 없이 무료<br>- 대용량의 테이터와 대규모 스토리지에 상관없이 일관된 속도 및 성능을 보장<br>- SQLite 및 CoreData 대비 빠른 속도<br>- Realm Studio툴을 사용하여 DB를 시각적으로 확인<br>- 몇 줄의 코드로 모든 작업을 처리 가능 |- 매우 작고 가벼워 전체 데이터 베이스를 하나의 디스크 파일에 저장할 수 있음 <br>- 서버로부터 독립적이고 설정이 간편 <br>- 다양한 OS에서 사용(Mac OS X, iOS, Android, Linux, Window) <br>- 여러 프로세스와 스레드로 부터 접근이 안전 |- SQLite보다 더 빠르게 저장된 기록을 가져옴 <br>- iOS에서 자체 제공하기 때문에 비교적 안정적임 |
|단점| - 외부 라이브러리를 설치해서 사용해야 하기 때문에 비교적 위험이 있음 <br>- 메인 스레드를 사용해서 다른 스레드 접근 시 에러 발생 <br>- 바이너리 용량이 큼 <br>- 다양한 쿼리를 지원하지 않음 | -  Date Time 같은 필드가 존재하지 않음 <br>- 성능이 Realm에 비해 좋지 않음 | - SQLite보다 많은 메모리를 사용하고, 더 많은 저장공간이 필요 <br>- 오버헤드가 발생할 가능성이 있음 <br>- 다른 플랫폼의 OS와 공유가 되지 않음 |

<br>

### 2. RemoteDB 비교
|종류|Firebase|CloudKit|
|---|--------|--------|
|특징|- 구글에서 제공하는 모바일 앱개발 플랫폼 <br>- NOSQL <br>- 실시간으로 사용자 간에 데이터를 저장하고 동기화함 <br>- 구조화된 JSON 및 Collection 데이터 처리에 적합 | - 앱 및 사용자 데이터를 iCloud 서버 (container)에 저장하기 위한 Apple의 프레임워크 <br>- 간단한 데이터는 Key-Value 형식으로 저장 가능함 |
|장점|- 루트 아래에 있는 데이터를 유연하게 관리 <br>- 직관적으로 데이터 베이스 구조 파악이 쉬움 <br>- Android와 공유가 가능 <br>- 비교적 저렴  <br>- Analytics를 제공하여 다수의 사용자의 앱 사용 패턴에 대한 통계를 확인| - 사용자를 자동으로 안전하게 인증 <br>- CoreData와 연동이 편함 <br>- 다른 애플의 기기와의 연동이 용이함 |
|단점|- 다른 트리의 다른 노드에 대한 참조는 수동으로 관리해야함 <br>- iOS보단 Android에 더 최적화 되어 있음 <br>- 종종 서버의 응답속도가 느려짐 <br>- 쿼리가 빈약 (or 문이나 Like문 같은 경우 데이터를 모두 받아와서 직접 필터링 해주어야한다.)| - Android를 지원하는데 한계가 있음 |

<br>

### 3. 프로젝트 적용 기술
**LocalDB: Realm**
Realm은 다른 플랫폼과의 연동이 가능하고 간단한 코드로 사용이 가능하며 다른 LocalDB에 비해 성능이 가장 좋아 선택했다.

**RemoteDB: Firebase**
Firebase는 다른 플랫폼과도 연동이 가능하고 비교적 저렴하며, 사용자의 앱 사용 패턴을 확인할 수 있어 마케팅에도 도움이 될 수 있어 Firebase로 선택했다.

<br>

### 4. 기술스택 고려사항
1. **하위 버전 호환성에는 문제가 없는가?**
	- Deployment Target: iOS 14이상으로 문제 없다.
		- Realm: iOS 11 이상 (SPM)
		- Firebase: iOS 10 이상 (SPM)
2. **안정적으로 운용 가능한가?**
	- 안정적으로 운용 가능함
		- Realm: 많은 곳에서 사용하고 있으며, 모바일에 최적화 되어 있다.
		- Firebase: 많은 곳에서 사용하고 있다.
3. **미래 지속가능성이 있는가?**
	- 미래 지속가능성 충분
		- Realm:  꾸준히 사용되고, 업데이트 되고 있다.
		- Firebase: 꾸준히 사용되고, 업데이트 되고 있다.
4. **리스크를 최소화 할 수 있는가? 알고있는 리스크는 무엇인가?**
	- 모두 외부의 라이브러리이기 때문에 리스크가 전혀 없다고 할 순 없지만 현저히 낮다고 판단된다.
		- Realm: 바이너리 용량이 큰편이어서 메모리 관리 시 주의 필요, 메인스레드에서만 사용할 수 있다. (CRUD 이외의 Realm 내부의 인스턴스를 다룰 때에도 메인스레드에서만 사용가능 하다.)
		- Firebase: 종종 서버의 응답속도가 느려진다는 단점있다.
5. **어떤 의존성 관리도구를 사용하여 관리할 수 있는가?**
	- 모두 Cocoa Pods, Carthage, SPM 사용 가능하다.
6. **이 앱의 요구기능에 적절한 선택인가?**
	- 프로젝트에서 사용 필요로 하는 기능과 성능에 대해서는 충분하다고 생각된다.
	- Deployment Target도 적절하다.

<br>
<br>

# STEP 2 : 프로젝트 할일 리스트 구현


## 고민한 점

### 1. ViewModel 타입
ViewModel에 맞는 데이터 타입을 하나 더 만들어서 사용하려고 하였으나,    
뷰에서 사용하는 데이터와 실제 모델의 데이터가 같아 뷰모델을 위한 데이터 타입을 만들지 않고 로직 내부에서 사용하는 모델을 그대로 사용하였다.

<br>

### 2. 메인화면의 상단바를 네비게이션으로 해야하는가?
네비게이션으로 해야할지 따로 바형태로 뷰를 만들어야할지 고민했지만,   
아이패드 전용앱으로서 Todo, Doing, Done 세가지의 리스트를 하나의 화면에서 보여주는 것이 중점이고 현재의 방향에서 네비게이션뷰가 사용될 일이 없다고 판단하였다. 이런 이유로 네비게이션으로 상단바를 따로 만들어 주었다.

<br>

### 3. dismiss하는 방식
뷰를 dismiss하는 방식을 두가지를 고민하였다.   
첫번째는 보여주는 뷰의 상태를 수정해서 스스로 닫도록 하는 방법이다.
보여주고 닫아야 하는 뷰에 environment property를 추가하여 presentationMode를 수정할 수 있도록 해주고 뷰를 닫아야할 때 dismiss를 호출한다.

```swift
// environment property 추가
@Environment(\.presentationMode) var presentationMode

// 뷰 dismiss
self.presentationMode.wrappedValue.dismiss()
```

두번째 방법은 바인딩을 이용하는 것이다.   
새로 띄운 뷰를 호출한 뷰에 바인딩을 전달하는 것으로 바인딩된 값을 띄워준 뷰에서 false로 하게 되면 뷰가 닫힌다.

```swift
// 새로운 뷰를 띄우도록 하는 뷰에서 설정
@State private var isShowTaskDetailView = false

.sheet(isPresented: $isShowTaskDetailView, onDismiss: nil) { 
    TaskDetailView(isShowTaskDetailView: $isShowTaskDetailView, task: task)
}

// 띄울 뷰
@Binding var isShowTaskDetailView: Bool

self.isShowTaskDetailView = false
```

<br>

### 4. SwipeActions
List의 row를 삭제하기 위해 SwipeActions를 사용하려고 하였으나 SwipeActions은 iOS15 이상부터 지원하는데 현재 프로젝트의 타겟 버전을 iOS14으로 설정하였기 때문에 사용하지 못했다.   
그래서 아래의 버전도 사용할 수 있는 `onDelete`를 사용하였다. SwipeActions가 이미지 버튼을 만들 수 있는 등 여러 기능이 있어 사용하고 싶었지만 1-2년 이후에 사용할 수 있을 것 같다.

<br>

## Trouble Shooting

### 1. List에서 row를 공백을 터치하면 동작하지 않는 문제
 - 문제점
	- row를 클릭시 글자 등 컨텐츠가 없는 곳을 클릭하면 터치기능이 동작하지 않음
 - 원인
	- 터치 제스처를 row에 컨텐츠를 감싸고 있는 스택에 지정해두었다. 그래서 스택의 width의 길이는 각 우리가 보는 각 row의 길이가 아니라 글자가 써있는 컨텐츠의 width였다.

```swift
VStack(alignment: .leading, spacing: 4) {
    title
    descrition
    deadline
}
.onTapGesture {
	// ...
}
```
 - 해결방안
 	- 스택의 width의 크기를 row의 width와 같게 해주고 contentShape을 통해서 인식할 수 있도록 하여 터치할 수 있도록 해준다.

```swift
VStack(alignment: .leading, spacing: 4) {
    title
    descrition
    deadline
}
.frame(maxWidth: .infinity, alignment: .leading)
.contentShape(Rectangle())
.onTapGesture {
	// ...
}
```

<br>

### 2. List에 row가 두 개 이상일 때 터치가 먹히지 않는 문제
- 문제점
	- row가 두 개 이상일 때 터치를 하면 List의 처음 row의 정보만 뜨고, 길게 터치하는 것은 먹히지 않음
- 원인
	- 기존에는 아래와 같이 for문 안에서 TaskListCellView에 제스처를 등록해주었다. for문안에서 뷰를 그리는 중에 제스처를 등록하여 제대로 작동하지 않았다.

```swift
List {
    ForEach(taskList) { task in
        TaskListCellView(task: task)
            .onTapGesture {
				// ...
            }
    }
}
```
- 해결방안
	- 뷰를 분리하여 TaskListCellView안의 스택에 제스처를 등록해주었다.

```swift
var body: some View {
    VStack(alignment: .leading, spacing: 4) {
        title
        descrition
        deadline
    }
    .onTapGesture {
		// ...
    }
}
```


## 1-5 PR 후 개선사항



[![top](https://img.shields.io/badge/top-%23000000.svg?&amp;style=for-the-badge&amp;logo=Acclaim&amp;logoColor=white&amp;)](#-프로젝트-관리-앱)
