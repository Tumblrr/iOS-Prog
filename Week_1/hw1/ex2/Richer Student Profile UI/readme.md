# Richer Student Profile UI

This project is a SwiftUI practice exercise to build a visually appealing student profile interface using multiple layout stacks and custom modifiers.

## 📸 App Screenshot


---

## 🛠 Answers to Analysis Questions (Which stacks are used?)

To achieve the layout requirements, I combined three main types of stacks in SwiftUI:

* **`ZStack` (Header & Overlapping):** Used to layer views on top of one another. Specifically, I used it in the header to place the background image (`pic2`) behind the header text ("Relax! Nothin is in control:))") and the settings icon. It also allows the circular avatar to visually overlap the header and the main white content card.
* **`VStack` (Main Content):** Used to arrange the core UI components vertically from top to bottom. It wraps the entire main content area, stacking the avatar, name/major texts, information cards, motto section, and the "Edit Profile" button in a column.
* **`HStack` (Info Rows & Alignments):** Used to place elements side by side horizontally. I utilized `HStack` to arrange the info cards in pairs (e.g., Student ID next to Age), to align the icon and text within the "Edit Profile" button, and to layout the custom bottom `TabView`.

---

## 🎨 My Customizations & Changes

Compared to the base example, I made several personalizations to make the UI my own:
1. **Personalized Data:** Updated the profile with my actual information (Name: Nguyễn Hoàng Bảo Hân, ID: SESEIU24008, Major: Space Engineering).
2. **Custom Background:** Replaced the default `LinearGradient` with a custom downloaded image (`pic2`) in the `Assets` catalog to make the header more lively.
3. **Motto & Vibe:** Changed the text quotes to reflect a more personal vibe ("FREE UR MIND!").
4. **UI Bug Fix (Avatar Clipping):** Modified the base layout implementation to fix an issue where the circular avatar's top half was clipped by the `.cornerRadius`. I resolved this by applying a custom `RoundedCorner` shape directly to the `.background` modifier instead of clipping the entire view hierarchy.
