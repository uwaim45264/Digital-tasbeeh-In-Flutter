# Digital Tasbeeh Flutter App

A simple and elegant Digital Tasbeeh counter app built with Flutter. This app allows users to keep track of their Tasbeeh count, save it for future reference, and reset the count as needed. The app also features an animation and smooth transitions for a delightful user experience.

## Features

- **Count Tasbeeh**: Tap the button to increment the count of your Tasbeeh.
- **Save History**: Save your Tasbeeh count history for later reference.
- **Reset Count**: Reset the current count with confirmation.
- **History**: View the saved history of your Tasbeeh counts.
- **Haptic Feedback**: Receive satisfying vibrations when incrementing the count.
- 
## Dependencies

- `flutter`: For building the cross-platform mobile application.
- `shared_preferences`: For storing the Tasbeeh count history locally.
- `flutter/services.dart`: For providing haptic feedback.
- `flutter/material.dart`: For building the UI components and applying theming.

## Installation

1. Clone this repository to your local machine:

    ```bash
    git clone https://github.com/yourusername/digital-tasbeeh-app.git
    ```

2. Navigate to the project directory:

    ```bash
    cd digital-tasbeeh-app
    ```

3. Install the dependencies:

    ```bash
    flutter pub get
    ```

4. Run the app:

    ```bash
    flutter run
    ```

## Usage

- **Home Screen**: The main screen where you can increment, save, or reset the count.
- **History**: View your saved Tasbeeh count history by tapping the history icon in the top right corner.
- **Reset Count**: Reset the current count with a confirmation dialog.
- **Save Count**: Save the current count to the history with a confirmation dialog.

## Code Overview

### `TasbeehHomePage` Widget

- **Incrementing Count**: The count is increased when the user taps the button, accompanied by animations and haptic feedback.
- **Saving Count**: Prompts the user to confirm saving the count and stores the count in `SharedPreferences` for persistent storage.
- **Resetting Count**: Asks for confirmation before resetting the count.
- **History**: The saved counts are displayed in the History Screen, with options to delete any count.

### Animations

- The app uses `AnimationController` for smooth button animations and `CurvedAnimation` for bounce effects.
- A background blur effect is used to create a visually pleasing experience.

## Screens

### Home Screen
- Displays the current Tasbeeh count and buttons for interacting with the count.
  
### History Screen
- Shows the list of saved Tasbeeh counts and provides options to delete entries.

## Contributing

Feel free to fork this repository, create issues, and submit pull requests. Contributions are always welcome!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- The app design is based on modern UI principles to ensure a smooth and user-friendly experience.
- Special thanks to the Flutter community for providing the resources and tools needed to create this app.
DEVELOPER :
SOFTWARE ENGINEER MUHAMMMAD UWAIM QURESHI
