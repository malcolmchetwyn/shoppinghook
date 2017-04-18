"SignUp-Screen---Step-1.png" & "SignUp-Screen---Step-2.png" text fields have the same validate logic as Talkie. 
All fields are mandatory. 
DOB formart: dd/mm/yyyy. 
Every button at the bottom, when the user clicks the button, replace the text with a spinner to show to user something is happening. Design is in this file "SignUp-Screen---Step-2.psd"


If the user clicks "dont allow"
	load screen "SignUp-Screen---Step-3dt.png" 
	when users click continue then load main application
elseif user click "Okay"
	load screen "SignUp-Screen---Step-3a---Contacts-Screen.png"
		if user click the "cross"
			load SMS screen "SignUp-Screen---Step-3b.png" with Text message to send. this will be a message plus the users name
			after user has sent a SMS take user back to contacts screen and show user as ticked see "SignUp-Screen---Step-3ct.png"
			RULE: user can only send the txt message to one user at a time.
		elseif user clicks the top right arrow then
			load main application



