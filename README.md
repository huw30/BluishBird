# Project 4 - *Name of App Here*

Time spent: **15** hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] Hamburger menu
   - [x] Dragging anywhere in the view should reveal the menu.
   - [x] The menu should include links to your profile, the home timeline, and the mentions view.
   - [x] The menu can look similar to the example or feel free to take liberty with the UI.
- [x] Profile page
   - [x] Contains the user header view
   - [x] Contains a section with the users basic stats: # tweets, # following, # followers
- [x] Home Timeline
   - [x] Tapping on a user image should bring up that user's profile page

The following **optional** features are implemented:

- [x] Profile Page
   - [x] Implement the paging view for the user description.
   - [x] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
   - [x] Pulling down the profile page should blur and resize the header image.
- [ ] Account switching
   - [ ] Long press on tab bar to bring up Account view with animation
   - [ ] Tap account to switch to
   - [ ] Include a plus button to Add an Account
   - [ ] Swipe to delete an account


The following **additional** features are implemented:

- [x] Profile page, Home timeline, and mentions timeline are all inhiriting from one file, and share code

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

  1. Did you implement the media entities into each tweet? 
  2. How did you implement the "reply, retweet, favorite" control group so that different screens are using it without repeating logic


## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='https://user-images.githubusercontent.com/5446130/31323645-9a265e32-ac5f-11e7-8454-12d0d7c1239d.gif' title='Profile' width='' alt='Profile' />
<img src='https://user-images.githubusercontent.com/5446130/31323563-564d13d2-ac5e-11e7-9dba-b46e4f0fda83.gif' title='menu' width='' alt='menu' />
<img src='https://user-images.githubusercontent.com/5446130/31323780-381a72c6-ac61-11e7-8b43-cf083b4e3788.gif' title='profiles' width='' alt='profiles' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

- Refactor code to make sure that profile view, home timeline and mentions are sharing code, no redundant code
- paging view took some time
- how to manage table view, table header and the profile background image, so that I can get the desired scroll behavior

## License

    Copyright Raina Wang

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
