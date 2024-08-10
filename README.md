


Quick common things to remember:
* Views inheret from the view that called them. So if I set some setitngs in a view and then call another one those settings will also be applied to the next view.


Here are some common errors and how to fix them:
Navagation title overlapping content.
If i used this in my main view
.onAppear(perform: {
  UICollectionView.appearance().contentInset.top = -35
})
All subsequent views will inheret this and will push everything up higher than it should be.
