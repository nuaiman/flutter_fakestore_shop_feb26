# Daraz-Style Product Listing Flutter Screen

This Flutter project demonstrates a **Daraz-style product listing screen** with proper **scroll and gesture coordination**, using the **Fakestore API** for product data along with a simple login/profile flow.

---

## Mandatory Explanation (Submission Requirements)

1. **Horizontal Swipe Implementation**  
   - Achieved using `TabBarView` controlled by `_tabController`.  
   - Swiping horizontally switches tabs without affecting vertical scrolling.

2. **Vertical Scroll Ownership**  
   - `NestedScrollView` owns the vertical scroll for the entire screen.  
   - Inner product grids/lists rely on the parent scroll, preventing conflicts and preserving scroll position across tabs.

3. **Trade-offs / Limitations**  
   - Pull-to-refresh updates only the current tab.  
   - Floating Action Button (FAB) visibility depends on a fixed scroll offset and may vary across devices.  
   - Currently implemented with 2 tabs; adding more requires updating `_tabController` and `TabBar` definitions.

---

## Features

- **Collapsible Header**  
  `SliverAppBar` collapses as the user scrolls, containing a banner and search bar.

- **Sticky TabBar**  
  Becomes pinned when the header collapses, remaining visible at the top.

- **Multiple Tabs**  
  - **Remote Products** – fetched from [Fakestore API](https://fakestoreapi.com/)  
  - **Local Products** – mock or locally stored data  

  Tabs can be switched by:  
  - **Tapping** the TabBar  
  - **Horizontal swipe** via `TabBarView`  

- **Single Vertical Scroll**  
  Entire screen scrolls with **one vertical scroll** using `NestedScrollView`, preventing scroll conflicts or jitter.

- **Pull-to-Refresh**  
  Refreshes the product list on the current tab without resetting scroll position.

- **Login & Profile**  
  Basic login flow with profile display.

---

## Architecture
The project uses a clean architecture approach:

lib/
├── core/          # Services and constants (Dio, SharedPreferences, API URLs)
├── features/
│   ├── auth/      # Login & profile
│   └── products/  # Remote and local products
├── models/        # Product and user models
└── screens/       # UI screens

### State Management

- **Riverpod AsyncNotifiers**  
  - `RemoteProductsNotifier` → fetches products from Fakestore API  
  - `LocalProductsNotifier` → manages local/mock products  
  - `AuthNotifier` → handles login and user profile

### Scroll & Gesture Ownership

- **Vertical Scroll** → owned by `NestedScrollView`  
  Ensures smooth scrolling without conflicts across tabs.

- **Horizontal Swipe** → handled by `TabBarView`  
  Only switches tabs horizontally, with no effect on vertical scrolling.

---

## Implementation Notes

1. **Horizontal Swipe**  
   - Managed by `TabBarView(controller: _tabController)`  
   - Swipe gestures are intentionally separate from vertical scrolling.

2. **Vertical Scroll Ownership**  
   - `NestedScrollView` controls all vertical movement.  
   - Inner `GridView` widgets use `NeverScrollableScrollPhysics()` removed to let the parent handle vertical scroll naturally.

3. **Trade-offs & Limitations**  
   - FAB visibility uses a fixed offset threshold; may vary on different devices.  
   - Pull-to-refresh updates only the active tab.  
   - Currently 2 tabs; adding more requires updating `_tabController` and `TabBar` definitions.

---

## Running the App

1. Clone the repository:
```bash
git clone https://github.com/nuaiman/flutter_fakestore_shop_feb26.git
cd <in to project>
flutter run
```
