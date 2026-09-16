
# My Daily Planner App

## 📸 App Screenshot
---

## 📝 Analyze & Reflect

**1. Which SwiftUI views did you use?**
I used several core SwiftUI views including `Text` for labels, `Image` (with SF Symbols) for icons, `Button` for interactivity (checking tasks and adding new ones), `ScrollView` for the main content area, and `TabView` for the bottom navigation bar.

**2. Which stacks did you use? Explain where.**
*   **`ZStack`**: Used in the top header to layer the greeting text and sun icon directly on top of the background `LinearGradient`.
*   **`VStack`**: Used to structure the main layout vertically (Header -> Date/Quote section -> Task List). It was also used inside the task rows to stack the task title directly above the category label.
*   **`HStack`**: Used extensively to place items side-by-side. For example, arranging the Date box next to the Quote box, positioning the "+ Add Task" button next to the "My Tasks" title, and aligning the checkbox, icon, text details, and time within each individual task row.

**3. What variables or constants did you define?**
*   **Constant (`let`)**: I defined `userName` to store my name for the header greeting.
*   **State Variable (`@State var`)**: I defined an array of `Task` objects called `tasks`. Using the `@State` property wrapper ensures that the UI automatically updates whenever a task is added or its completion status is toggled. I also used `@Binding` in the child view (`TaskRowView`) to modify the parent's data.

**4. Identify at least one modifier you used.**
I used the `.strikethrough(task.isCompleted, color: .gray)` modifier on the task title text. This dynamically crosses out the text when the user taps the checkbox. I also used `.padding()`, `.background()`, and `.cornerRadius()` frequently to create the card-like appearance for the UI components.

**5. What did you change or customize? Why?**
*   **Personalized Data:** I populated the initial array with tasks relevant to my own schedule (e.g., Quantum Mechanics, Road Cycling, SQL Lab) to make the app feel personalized and realistic.
*   **Dynamic Styling:** Instead of static styling, I created helper functions (`getIcon` and `getColor`) to automatically assign specific SF Symbols and UI colors based on the task's category (Study, Health, Work, Personal). This visual categorization makes the task list much easier to scan quickly.
