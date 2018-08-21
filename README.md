# MelanomaDiagnosis-App

# Description: 
iOS app that allows users to take pictures of suspicious skin lesion, receive a diagnosis from a melanoma classification model, and view the diagnosis and related figures. (iPhone7 requirements)

# To Run: 
Download the workspace (takePicBrianAdvent2).

# Most Relevant Files:

Name: ViewController.swift
Description: 

Initializes app and camera feed. If an image is taken, passes it onto PhotoViewController.

Name: PhotoViewController.swift
Description: 

Allows users to view their taken photo and retake if needed. Assigns the image a unique identifying tag, uploads the image to Dropbox, which connects to a remote melanoma classification model that extracts melanoma indicative features from the image, applies learned parameters onto the features, and outputs a diagnosis and related figures to Dropbox with the same identifying tag as the original image. The app then receives the results and passes it to FigureViewController.

Name: FigureViewController.swift
Description: 

Displays any figures corresponding to skin lesion features, such such as pigmented networks and color variation.

# Credits: 
Camera App Swift Tutorial by Brian Advent (https://www.youtube.com/watch?v=Zv4cJf5qdu0)
Daniel Gareau (Mentor)
