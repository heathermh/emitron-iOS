/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct MainView: View {
  
  @EnvironmentObject var userMC: UserMC
  @EnvironmentObject var appState: AppState
  
  var body: some View {
    return contentView
      .background(Color.backgroundColor)
  }
  
  private var contentView: AnyView {
    guard let user = userMC.user else {
      return loginView
    }
    
    switch userMC.state {
    case .failed:
      return loginView
    case .initial, .loading:
      userMC.fetchPermissions()
      return tabBarView()
    case .hasData:
      if let permissions = user.permissions, permissions.contains(where: { $0.tag != .none } ) {
        return tabBarView()
      } else {
        return logoutView
      }
    }
  }
  
  private func tabBarView() -> AnyView {
    guard let dataManager = DataManager.current else { fatalError("Data manager is nil in MainView") }
    
    let libraryContentsVM = dataManager.libraryContentsVM
    let downloadsMC = dataManager.downloadsMC
    let filters = dataManager.filters

    let libraryView = LibraryView(downloadsMC: downloadsMC)
      .environmentObject(libraryContentsVM)
      .environmentObject(filters)
    
    let domainsMC = dataManager.domainsMC
    let bookmarkContentsMC = dataManager.bookmarkContentMC
    let inProgressContentVM = dataManager.inProgressContentVM
    let completedContentVM = dataManager.completedContentVM
    
    let myTutorialsView = MyTutorialView(state: .inProgress)
      .environmentObject(domainsMC)
      .environmentObject(inProgressContentVM)
      .environmentObject(completedContentVM)
      .environmentObject(bookmarkContentsMC)
    
    let downloadsView = DownloadsView(contentScreen: .downloads, downloadsMC: downloadsMC)
    
    return AnyView(
      TabNavView(libraryView: AnyView(libraryView),
                 myTutorialsView: AnyView(myTutorialsView),
                 downloadsView: AnyView(downloadsView))
        .environmentObject(AppState())
    )
  }
  
  private var logoutView: AnyView {
    AnyView(VStack {
      
      Image("logo")
        .padding([.top], 88)
      
      Spacer()
      
      Text("No access")
        .font(.uiTitle1)
        .foregroundColor(.titleText)
        .padding([.bottom], 15)
        .multilineTextAlignment(.center)
      
      Text("The raywenderlich.com mobile app is only available to subscribers. ")
        .font(.uiLabel)
        .foregroundColor(.contentText)
        .multilineTextAlignment(.center)
        .padding([.leading, .trailing], 55)
      
      Spacer()
      
      MainButtonView(title: "Sign Out", type: .destructive(withArrow: true)) {
        self.userMC.logout()
      }
      .padding([.leading, .trailing], 18)
      .padding([.bottom], 38)
    }
    .background(Color.backgroundColor)
    .edgesIgnoringSafeArea([.all])
    )
  }
  
  private var loginView: AnyView {
    AnyView(VStack {
      
      Image("logo")
        .padding([.top], 88)
      
      Spacer()
      
      Image("welcomeArtwork1")
        .padding([.bottom], 50)
      
      Text("Watch anytime,\nanywhere")
        .font(.uiTitle1)
        .foregroundColor(.titleText)
        .padding([.bottom], 15)
        .multilineTextAlignment(.center)
      
      Text("raywenderlich Subscribers can watch over\n2,000+ video tutorials on iPhone and iPad.")
        .font(.uiLabel)
        .foregroundColor(.contentText)
        .multilineTextAlignment(.center)
      
      Spacer()
      
      MainButtonView(title: "Sign In", type: .primary(withArrow: true)) {
        self.userMC.login()
      }
      .padding([.leading, .trailing], 18)
      .padding([.bottom], 38)
    }
    .background(Color.backgroundColor)
    .edgesIgnoringSafeArea([.all])
    )
  }
}
