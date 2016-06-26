#include <EEPROM.h>
#include <SoftwareSerial.h>

#define BUTTON 3
//#define RESET 7
#define PASSWORDSIZE 20 // last one for setting 0, so users can set 19 chars.
#define LED 13
#define LOCKSTATE 2

void(* resetFunc) (void) = 0; //declare reset function at address 0

SoftwareSerial mySerial(8, 9); // RX, TX

int count = 0;
int finish = 0;
int buttonState = 1;
int loopPosition = 0;

char password[PASSWORDSIZE] = {0};
char userInput[PASSWORDSIZE] = {0};

void setup() {
  //digitalWrite(RESET, HIGH);
  //pinMode(RESET, OUTPUT);
  pinMode(LED, OUTPUT);
  pinMode(LOCKSTATE, OUTPUT);
  pinMode(BUTTON, INPUT_PULLUP);
  Serial.begin(9600);
  mySerial.begin(19200);
  Serial.println("just rebooted");
  int state = loadPsdFromROM(password, 0); // 1 is successful, 0 is no password inside.
  if(state) {
    Serial.println("password is loaded from ROM.");
    mySerial.println("password is loaded from ROM.");
    Serial.print("password is ");
    mySerial.print("password is ");
    Serial.println(password);
    mySerial.println(password);
  } else {
    Serial.println("No Password was found in the ROM");
    mySerial.println("No Password was found in the ROM");
    strncpy(password,"0000",sizeof("0000"));
    Serial.println("just set a default password to 0000");
    mySerial.println("just set a default password to 0000");
  }
  Serial.println("Please Enter Password for matching: ");
  mySerial.println("Please Enter Password for matching: ");
}

void loop() {
  if (buttonState == HIGH) {
    if(mySerial.available() > 0){
      char eachChar = mySerial.read();
      if( count >= PASSWORDSIZE - 1 ) { // limit the user's input size to prevent overflow.
        resetPasswordArray(userInput, sizeof(userInput)); // once users input more than the size,
        count = 0; // it will reset the array for user's input. 
      }
      if(eachChar == '\n'){
        finish = 1;
        userInput[count] = '\0';
        count = 0;
      } else {
        userInput[count++] = eachChar;
        userInput[count] = '\0';
      }

    }
    if (finish) {
      int correctOrNot = CheckPassword(password, userInput,sizeof(password), sizeof(userInput));
      if(correctOrNot){
        Serial.println("password correct");
        mySerial.println("password correct");
        Serial.println("Unlock");
        mySerial.println("Unlock");
        digitalWrite(LED, HIGH);
        digitalWrite(LOCKSTATE, HIGH);
        delay(2000);
        digitalWrite(LED, LOW);
        digitalWrite(LOCKSTATE, LOW);
        // "Unlock here"
      } else {
        Serial.println("wrong password.");
        mySerial.println("wrong password.");
      }
      resetPasswordArray(userInput, sizeof(userInput));
      Serial.println("Please Enter Password for matching: ");
      mySerial.println("Please Enter Password for matching: ");
      finish = 0;
    }
    buttonState = digitalRead(BUTTON);
  } else { // when user pressed the reset button, it transits to here.
    if (loopPosition == 0){
      Serial.println("Please Enter New Password: ");
      mySerial.println("Please Enter New Password: ");
      loopPosition++;
      count = 0;
      resetPasswordArray(userInput, sizeof(userInput));
    }
    if(mySerial.available() > 0){
      char eachChar = mySerial.read();
      if( count >= PASSWORDSIZE - 1 ) { // limit the user's input size to prevent overflow.
        resetPasswordArray(userInput, sizeof(userInput));
        count = 0;
      }
      if(eachChar == '\n'){
        finish = 1;
        userInput[count] = '\0';
        count = 0;
      } else {
        userInput[count++] = eachChar;
        userInput[count] = '\0';
      }
    }
    if (finish) {
      resetROM();
      Serial.println("just clean up the old password from the ROM");
      mySerial.println("just clean up the old password from the ROM");
      int len = strlen(userInput);
      if(len){
        savePsdToROM((byte *)userInput, len, 0);
        Serial.println("saved to ROM");
        mySerial.println("saved to ROM");
      } else Serial.println("nothing was saved to ROM");
      finish = 0;
      Serial.println("reboot now");
      mySerial.println("reboot now");
      delay(2000);
      resetFunc();
      //digitalWrite(RESET, LOW);
    }  
  }
}

int loadPsdFromROM(char *spaceForLoad, int addr){
  if(EEPROM.read(addr) == 0) return 0;
  for( ; EEPROM.read(addr) != 0; addr++, spaceForLoad++){
    *spaceForLoad = (char)EEPROM.read(addr);
  }
  return 1;
}

void savePsdToROM(byte *psd, int len, int startAddr){
  for(int step = 0; step < len; step++, startAddr++, psd++){
    EEPROM.update(startAddr, *psd);
  }
}

char CheckPassword(char *psd, char *userInput,int psdSize, int userInputSize) {
  if(psdSize != userInputSize) {
    return 0;
  }
  for(int step = 0; psd[step] == userInput[step]; step++) {
    if(step == psdSize - 1){
      return 1;
    }
  }
  return 0;
}

int resetROM(){
  for(int step = 0; EEPROM.read(step) != 0; step++){
    EEPROM.update(step, 0);
  }
}

void resetPasswordArray(char *psdArr, int psdArrSize){
  for(int index = 0; index < psdArrSize; index++){
        psdArr[index] = 0;  
  }
}

