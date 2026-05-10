# Habitzzz — Habit Tracker App Case Study

---

## Project Overview

Habitzzz is a mobile app that helps people track their daily habits and tasks. It was built using Flutter (a framework for making apps on Android, iOS, and Web) and Firebase (a backend service for authentication and database).

| Item | Details |
|---|---|
| App Name | Habitzzz |
| Built With | Flutter + Dart |
| Backend | Firebase Auth & Firestore |
| Platform | Android (main), also works on iOS and Web |
| Timeline | April 14 — May 10, 2026 (about 4 weeks) |
| Developer | Solo |

---

## Problem Statement

There are many habit tracker apps out there, but most of them have problems:

1. **Too complicated** — Lots of features that confuse people who just want to track a few habits.
2. **No priority system** — All tasks are treated the same. A high-importance task like "Exercise" and a simple task like "Drink water" look the same.
3. **Hard to see progress** — Users don't know if they're improving because there's no clear way to see their stats.
4. **No dark mode** — Many apps only have light mode, which is annoying at night.
5. **One type of task only** — Some habits are one-day things (like "Doctor appointment") and others are over many days (like "Read this book this week"). Most apps don't handle both well.

The main question was: *How do I make a simple habit tracker that helps people stay consistent without overwhelming them?*

---

## Proposed Solution

Habitzzz solves these problems by keeping things simple:

- **Simple task management** — Add, edit, delete, and mark tasks as done. That's it.
- **Priority colors** — High = Red, Medium = Blue, Easy (Low) = Yellow. You can see at a glance what's important.
- **Filter tabs** — Buttons for All, High, Medium, Easy so you can focus on what matters.
- **Streak counter** — Shows how many days in a row you've done your tasks. This makes you want to keep going.
- **Stats page** — A pie chart and calendar that show how you're doing each month.
- **Dark mode** — Switch between light and dark theme, and it remembers your choice.
- **Secure login** — Email/password login with Firebase so your data is safe.

---

## Requirement Gathering & Analysis

Since I was building this alone, I thought about what I would want in a habit tracker.

### What the app needed to do:

**Login & Profile**
- Users should be able to sign up and log in with email and password.
- Users should see their name and email on a profile page.
- Users should be able to change their display name.
- Password reset should work through email.
- The app should remember the user so they don't have to log in every time.

**Tasks**
- Users should be able to add a task with a name, description, date(s), and priority.
- Users should be able to edit or delete tasks.
- Tasks can be a single day or a date range (like a week).
- Three priorities: High (red), Medium (blue), Easy (yellow).
- Users can mark tasks as done/not done.

**Dashboard**
- Show a summary card with total tasks, done count, and streak.
- Four filter tabs: All, High, Medium, Easy.
- Greeting based on time of day (Good morning / afternoon / evening).
- Empty state for new users who have no tasks yet.

**Streak Tracking**
- Count how many consecutive days the user completed at least one task.
- If user missed today AND yesterday, streak resets to 0.
- Streak updates immediately when a task is toggled.

**Statistics**
- Monthly calendar view.
- Pie chart showing tasks by priority.
- Numbers: Total tasks, tasks completed, completion rate.
- List of all tasks for the month with done/pending status.

**Look & Feel**
- Light and dark mode toggle, saved so it stays.
- Works in both portrait and landscape.
- A cool splash screen when the app opens.
- Custom app icon.

### Database Design

**Users collection** (one document per user):
- name, email, createdAt

**Tasks subcollection** (inside each user):
- name, description, singleDate or startDate+endDate, isDuration (true/false), priority (high/medium/low), isDone (true/false), createdAt, userId

---

## Project Planning

I split the work into phases:

### Phase 1: Setup (April 14)
- Created GitHub repository for version control and backup.
- Set up the Flutter project from scratch.

### Phase 2: Authentication Screens (April 22)
- Splash screen with animation (fade + scale, 3 seconds).
- Login screen.
- Registration screen.
- Connected to Firebase Auth.

### Phase 3: Backend & Core Features (May 4 — May 5)
- Set up Firebase project (Firestore + Auth).
- Dashboard with stats card and task list.
- Add task dialog.
- Edit task dialog.
- Delete task.
- Priority system with colors.
- Filter tabs.
- Streak tracking.

### Phase 4: Statistics & Profile (May 4 — May 6)
- Statistics screen with pie chart and calendar.
- Profile screen with theme toggle and logout.
- Edit profile screen.

### Phase 5: Final Polish (May 10)
- Dark/light mode fine-tuning.
- Responsive layout for landscape.
- Custom app icon.
- Final testing.

---

## Challenges & Solutions

### Challenge 1: Streak Algorithm

**Problem**: I had to figure out how to count consecutive days. What if a task has multiple dates (like a range)? What if the user just started and has no tasks yet?

**Solution**: I made the algorithm work like this:
1. Get all completed tasks.
2. Make a list of unique dates (one date per task, for range tasks I only take the start date).
3. Check if today or yesterday has a completed task. If no, streak is 0.
4. Count backwards day by day until a day is missing.

It's not perfect (range tasks only count their start date), but it works for a first version.

### Challenge 2: Real-time Updates

**Problem**: When a user marks a task done, the stats page should also update. But each screen had its own connection to the database.

**Solution**: I used Firebase's real-time listener feature. Each screen listens for changes and updates automatically. This means when you toggle a task on the dashboard and switch to stats, the data is already updated.

### Challenge 3: Manual Theme Colors

**Problem**: For dark and light mode, I had to define colors everywhere. Every screen checks "is dark mode?" and picks colors manually. This meant lots of repeated code.

**Solution**: I just accepted the repetition for now. It works and each screen is clear about its colors. I can clean it up later by using a central color file.

### Challenge 4: Dialog vs Full Screen for Task Form

**Problem**: Should the "Add Task" form be a popup dialog or a whole new screen? Dialogs are simpler but hard to scroll with the keyboard open.

**Solution**: I used dialogs because they're faster to build and keep the user on the dashboard. They work fine for the 5-6 fields in the form.

### Challenge 5: Pie Chart Not Really Useful

**Problem**: The pie chart gives every task the same size ("value: 1") so it's just counting tasks by color. It doesn't show completion or effort.

**Solution**: I decided it's better than nothing for the MVP. The real useful info is the numbers (total, done, completion rate). The pie chart is just a visual bonus.

### Challenge 6: No Offline Support

**Problem**: If there's no internet, the app shows nothing. Firestore has a built-in offline mode but I didn't set it up.

**Solution**: I'll add it in the next version. It's literally one line of code I missed.

### Challenge 7: Web Not Fully Working

**Problem**: The web version has placeholder keys for Firebase so it won't actually run on web.

**Solution**: I focused on Android first. Web support is there but needs the real Firebase credentials. Just need to copy them from the Firebase Console.

### Challenge 8: Staying on Track

**Problem**: Midway I wanted to add more features (notifications, data export, sharing with friends).

**Solution**: I made a list and forced myself to only build what was absolutely needed. I noted the rest for later. This was the hardest part — saying no to cool features.

---

## Outcome / Results

### What got built:

| Feature | Status |
|---|---|
| User sign up / login | ✅ Done |
| Password reset | ✅ Done |
| Profile view & edit | ✅ Done |
| Add / Edit / Delete tasks | ✅ Done |
| Single date & date range tasks | ✅ Done |
| Priority system (High/Medium/Easy) | ✅ Done |
| Filter tabs (All/High/Medium/Easy) | ✅ Done |
| Streak counter | ✅ Done |
| Dark / Light mode | ✅ Done |
| Statistics (pie chart, calendar, numbers) | ✅ Done |
| Responsive layout (portrait + landscape) | ✅ Done |
| Splash screen with animation | ✅ Done |
| Custom app icon | ✅ Done |
| Help & About screens | ✅ Done |

### App stats:
- 10 Dart files
- About 2,200 lines of code
- 8 external packages used
- Works on Android, mostly works on iOS and Web
- 4 weeks from start to finish

---

## Key Learnings

### What I learned making this:

1. **Plan before coding**. Writing down what the app should do (like the BRD) saved me a lot of confusion later. Every time I got stuck, I went back to my plan.

2. **Scope is hard to control**. The biggest challenge was not adding too many features. I learned to ask "is this needed for the app to work?" If no, it goes on a "later" list.

3. **Streak algorithms are tricky**. What seems like a simple feature (count consecutive days) has lots of edge cases — what if the user is in a different timezone? What if a task spans 5 days? What if the user set a task for tomorrow by mistake?

4. **Dark mode is easy to set up but hard to perfect**. Making every screen look good in both themes takes time. You have to check every text color, background, and border.

5. **Real devices matter**. Some bugs only show up on a real phone — like the keyboard covering the form, or date pickers behaving differently.

6. **Version control is worth it**. Even for a solo project, Git helped me try things without fear of breaking everything.

7. **Done is better than perfect**. The app isn't perfect (no offline, pie chart could be better, some repeated code) but it works and does what it needs to do.

---

## Future Scope

### Things to add next:

**Short term (easy fixes)**:
- Enable offline mode (1 line of code)
- Fix the web Firebase keys
- Add swipe to refresh on dashboard
- Better loading animations

**Medium term (next few months)**:
- Push notifications to remind users to do their habits
- Habit templates (pre-made lists like "Morning Routine", "Fitness")
- Streak freeze (allow one missed day per week without losing streak)
- Export data as CSV

**Long term (maybe)**:
- Categories/tags for habits (Work, Health, Personal)
- Share streaks with friends
- Wear OS / Apple Watch support
- Premium version with advanced stats

---

## Final Thoughts

Habitzzz is a simple habit tracker that does the basics well. It lets users create tasks, organize them by priority, track their streak, and see their progress. The whole thing was built in 4 weeks by one person who was learning as they went.

It's not the most advanced habit tracker out there, but it solves the core problem: helping people stay consistent with their habits. And sometimes simple is better.
