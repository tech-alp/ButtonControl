const int pot1 = A0;
const int pot2 = A1;
const int button = 2;

//POTs pins
uint16_t firstSensor;
uint16_t secondSensor;
uint16_t thirdSensor;
int inByte;

//LED pins
const int rLed = 10;
const int gLed = 6;
const int bLed = 5;

void setup()
{
  Serial.begin(9600);
  pinMode(button,INPUT); 

  establishContact();
}

void loop()
{
  if(Serial.available() > 0)
  {
     //get incoming byte
     inByte = Serial.read();
     //read the first analog input from pot1 and scaling 0 - 360 
     firstSensor  = map(analogRead(pot1),0,1023,0,360);
     //delay 10ms to let the ADC recover:
     delay(10);
     //read second analog input from pot2, scaling 0 - 360
     secondSensor = map(analogRead(pot2),0,1023,0,360);
     //read switch
     thirdSensor  = digitalRead(button);

     //For RGB leds
     switch(inByte) {
      case('R'): {
        digitalWrite(rLed,HIGH);
        digitalWrite(gLed,LOW);
        digitalWrite(bLed,LOW);
        break;
      }
      
      case('G'): {
        digitalWrite(rLed,LOW);
        digitalWrite(gLed,HIGH);
        digitalWrite(bLed,LOW);
        break;
      }
      case('B'): {
        digitalWrite(rLed,LOW);
        digitalWrite(gLed,LOW);
        digitalWrite(bLed,HIGH);
        break;
      }
      
      default: {
        digitalWrite(rLed,LOW);
        digitalWrite(gLed,LOW);
        digitalWrite(bLed,LOW);
      }     
     }

     Serial.print(firstSensor);
     Serial.print(" ");
     Serial.print(secondSensor);
     Serial.print(" ");
     Serial.print(thirdSensor);
     Serial.println("");
     
  }

}

//Wait for communication device and MATLAB or another program
void establishContact() {
    while(Serial.available() <= 0)
    {
      Serial.print("A");
      delay(300);
    }
}
