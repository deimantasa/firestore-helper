# Firestore Helper - use Firestore easier.

Helper package which abstracts Firestore APIs and expose most reusable methods.

## Motivation
After spending years with coding in `Dart` (`Flutter`) and using `Firestore`, I've realised that I'm writing tons  
of same code over and over again. Within the same project or a new one.  

Within long period of time, I've shaped this library internally (back then - a class), trying to make it as flexible as reusable  
to my needs. It is now successfully being reused in many of my projects thus I've decided to share it with everyone.  
I believe it can be extremely easy entry point for many folks starting to integrate `Flutter` with `Firestore`. As leveraging  
real-time updates have never been easier.

## Demo  
In order to run `example` app on your device:  
1. Create a new `firebase` project;
2. Enable `Firestore` (simple click on it, select the server and voilia);
3. Create a new project for Android/iOS device (package must be called `com.firestorehelper`) and put files (`google-services.json`/`GoogleService-Info.plist`) into right directories;
4. Build the app. Now you are having a fully running DEMO app.  

### Full DEMO
Video below demonstrates CRUD and real-time listening capabilities using this package and `Firestore`. 

https://user-images.githubusercontent.com/12739071/122766465-c2016f00-d2cb-11eb-923c-661216c5bd21.mp4  

### Snippets  
Just a few methods to quickly show this package capabilities. Watch [full demo](https://user-images.githubusercontent.com/12739071/122766465-c2016f00-d2cb-11eb-923c-661216c5bd21.mp4) for in-depth dive.

#### Add new document
!["Add new document - real-time"](https://user-images.githubusercontent.com/12739071/122839190-be98d280-d321-11eb-904d-303ce71304ef.gif)  

#### Update existing document  
!["Update existing document - real-time"](https://user-images.githubusercontent.com/12739071/122839189-be003c00-d321-11eb-9c88-e594df01cec4.gif)  

#### Remove document
!["Remove document - real-time](https://user-images.githubusercontent.com/12739071/122839186-bc367880-d321-11eb-8cd4-c25d41c32c81.gif)  

## Feature-set

| Feature                                       |   Available    |  Pending  |
| --------------------------------------------- | :------------: | :-------: | 
| Add Document To Collection                    |       ✅       |           |  
| Add Document To SubCollection                 |       ✅       |           |
| Remove Document From Collection               |       ✅       |           |
| Remove Document From SubCollection            |       ✅       |           |
| Update Document in Collection                 |       ✅       |           |
| Update Document in SubCollection              |       ✅       |           |
| Remove Documents from Collection by Query     |       ✅       |           |
| Listen for a Document in Collection           |       ✅       |           |
| Listen for a Document in SubCollection        |       ✅       |           |
| Listen for a Query                            |       ✅       |           |
| Get list of Items                             |       ✅       |           |
| Get an Item                                   |       ✅       |           |
| Check if more items are available             |       ✅       |           |

## Extra Features  

Feature requests are welcome. Please file an issue.

# Tutorial  

## Initialisation  

Initialise helper.  
```
final FirestoreHelper _firestoreHelper = FirestoreHelper(
    includeAdditionalFields: true,
    isLoggingEnabled: !kReleaseMode,
  );
```
- `includeAdditionalFields`  
it will include `createdAt` and `updatedAt` fields to every single document.  
  - `createdAt` is only included once document is being created.  
  - `updatedAt` is included when document is created. Its value is updated with current time when particular document is updated.  

- `isLoggingEnabled`  
enables extra logging, which helps to debug faster. It is recommended to disable logging in production builds,
thus we simply specify that if build is in release mode - logs won't be enabled. Otherwise - logs will be enabled.

### Data manipulation  
For various CRUD operations, simply use exposed methods from `FirebaseHelper`. For example:  
```
bool isSuccess = await _firestoreHelper.addDocument(collection, update);

bool isSuccess = await _firestoreHelper.deleteSubCollectionDocument(collection: collection, documentId: documentId, subCollection: subCollection, subCollectionDocumentId: subCollectionDocumentId);

T? item = await _firestoreHelper.getElement<T>(collection, documentId, logReference, onDocumentSnapshot: onDocumentSnapshot);

List<T>? items = await _firestoreHelper.getElements<T>(query: query, logReference: logReference, onDocumentSnapshot: onDocumentSnapshot);
```

Methods are equipped with logging mechanism which will give you much faster way of catching any potential bugs.  

### Data listening (Real-Time)  
For data listening, `streamSubscription` is exposed which let's you take over control over it by yourself.  
You can have it on page lifecycle or provider lifecycle. Don't forget to `dispose` it once you are not using it anymore!  

Example for page lifecycle:
```
your stateful widget
..
  // Declaring list where we will store all of the subscriptions.
  final List<StreamSubscription> _streamSubscriptions = [];

  @override
  void initState() {
    super.initState();
    
    // Initialise subscriptions for real-time updates.
    final StreamSubscription streamSubscription = _firestoreHelper.listenToElementsStream(
        logReference: 'some helpful message',
        query: FirebaseFirestore.instance.collection(myCollectionName),
        onDocumentChange: (documentChange) {
          setState(() {
            switch (documentChange.type) {
              case DocumentChangeType.added:
                // Do something when item was added.
                break;
              case DocumentChangeType.modified:
                // Do something when item was updated.
                break;
              case DocumentChangeType.removed:
                // Do something when item was removed.
                break;
            }
          });
        });
    // Add subscription to the list.
    _streamSubscriptions.add(streamSubscription);
  }

  @override
  void dispose() {
    // Cancel all subscriptions.
    _streamSubscriptions.forEach((element) {
      element.cancel();
    });
    _streamSubscriptions.clear();
    super.dispose();
  }
```
List of `StreamSubscription` is very useful here, because once we have a pagination, we will continuously  
add new `StreamSubscription`s there in order to have all real-time updates for every single visible item.  

By the way - to understand if we can continue paginate, use 
```
bool areMoreItemsAvailable = await _firestoreHelper.areMoreElementsAvailable(query: query, lastDocumentSnapshot: lastDocumentSnapshot, onDocumentSnapshot: onDocumentSnapshot);
```

### BONUS  
You can follow [modelling from DEMO project](https://github.com/deimantasa/firestore-helper/blob/main/example/lib/note.dart) - this way you can very easily parse changes from `Firestore`. For instance, when listening to `document` changes, use
```
  factory Note.fromFirestore(DocumentSnapshot documentSnapshot) {
    final Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
    final Note note = _$NoteFromJson(data);

    note.documentSnapshot = documentSnapshot;
    return note;
  }
```
And when listening for `query` changes use
```
 factory Note.fromFirestoreChanged(DocumentChange documentChange) {
    final Map<String, dynamic> data = documentChange.doc.data() as Map<String, dynamic>;
    final Note note = _$NoteFromJson(data);

    note.documentSnapshot = documentChange.doc;
    note.documentChangeType = documentChange.type;
    return note;
  }
```

## Donations
If you find this package helpful, donations are welcome!
- Bitcoin
-- `bc1q6ze04kw5s6dvptk22m9l0yjk43uewykfeks0tj`
- Nano
-- `nano_3pozzop44i7kyz4afg7teno41w4sm8q1genyu9rwdxmidfszpzjxitxq4js7`
- Monero
-- `44yBuwJXmTmc1fEDaxSKTwVz9As3FkzyHZDqmwCXSnNSWi9tUyieeyt2mgnpzusHFRRKcp7p31jAh9CN1G6dZb3F2MT2j3J`
