

# Homework 1: Build a Student Card

## 4. Analyze & Explain

**1. Which SwiftUI views did you use?**
I used `Text` for displaying string data (Name, ID, GPA, Status), `Image` with SF Symbols for the icons (avatar and GPA chart), and `Circle` as the background shape for the avatar.

**2. Which layout containers did you use?**
- `HStack`: Used as the main container to place the Avatar and Text Information side by side. Also used to place the Name and Status badge on the same line.
- `VStack`: Used to arrange the text rows (Name, Student ID, GPA) vertically from top to bottom.
- `ZStack`: Used to place the graduation cap image directly on top of the circular background.

**3. What variables or constants did you define?**
- `studentName` (let, String): Stores the student's name.
- `studentID` (let, String): Stores the student ID.
- `status` (let, String): Stores the active status text.
- `gpa` (var, Double): Stores the GPA value, which could be updated later.

**4. Identify at least one modifier you used. Explain what it does.**
I used the `.cornerRadius(15)` modifier on the main HStack to round the corners of the card background. I also used `.shadow(...)` to create a depth effect, making the card pop out from the background.

**5. What did you change or customize compared to the sample? Why?**
I customized the Status Badge by adding a `.background(Color.green.opacity(0.2))` and rounded corners to make it look like a modern UI tag. I also used SF Symbols instead of an image for a cleaner, vector-based avatar.
