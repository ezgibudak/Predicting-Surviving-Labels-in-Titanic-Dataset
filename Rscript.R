library(tidyverse)
library(ggplot2)
library(dplyr)
library(randomForest)

# Loading data sets
train <- read.csv("train.csv")
test <- read.csv("test.csv")

# Exploring train data

summary(train)
colSums(is.na(train))

# Handling with missing data

train$Age[which(is.na(train$Age))] <- mean(train$Age,na.rm=TRUE)

train$Embarked[which(train$Embarked=="")] <- "S"
train$Embarked <- factor(train$Embarked)

# Adding new vairables

train$aloneornot <- ifelse((train$SibSp<1 & train$Parch <1),0,1)

train$youngness <- ifelse((train$Age<18),"child",
                          ifelse((train$Age >= 18) & (train$Age < 40), 
                                 "young","old"))

# Removing unnecessary variables
colnames(train)
train <- train[,c(1,2,3,5,6,7,8,11,12,13)]

# Changing data types

str(train)

train$Survived <- as.factor(train$Survived)
train$Pclass <- as.factor(train$Pclass)
train$aloneornot <- as.factor(train$aloneornot)
train$youngness <- as.factor(train$youngness)

# Visualizing

## Pclass-Sex surviving percentage
Cl1 <- train %>% group_by(Sex,Pclass) %>% summarise(count=n())

Cl2 <- train %>% group_by(Sex,Pclass,Survived) %>% 
  filter(Survived==1) %>% summarise(count=n())

Cl <- merge(Cl1,Cl2,by=c("Sex","Pclass"),all=TRUE) 
Cl <- Cl %>% mutate(perc=Cl$count.y/Cl$count.x*100)

Cl %>% ggplot() + geom_bar(aes(x=Pclass,y=perc,fill=Sex),stat = "identity",
                           position = position_dodge())

## Pclass-youngness surviving percentage
yp1 <- train %>% group_by(youngness, Pclass) %>% summarise(count=n())

yp2 <- train %>% group_by(youngness, Pclass, Survived) %>% 
  filter(Survived==1) %>% summarise(count=n())

yp <- merge(yp1,yp2,by=c("youngness","Pclass"),all=TRUE) 
yp <- yp %>% mutate(perc=yp$count.y/yp$count.x*100)

yp %>% ggplot() + geom_bar(aes(x=Pclass,y=perc,fill=youngness),stat = "identity",
                           position = position_dodge())

## youngness-Sex surviving percentage
ys1 <- train %>% group_by(youngness, Sex) %>% summarise(count=n())

ys2 <- train %>% group_by(youngness, Sex, Survived) %>% 
  filter(Survived==1) %>% summarise(count=n())

ys <- merge(ys1,ys2,by=c("youngness","Sex"),all=TRUE) 
ys <- ys %>% mutate(perc=ys$count.y/ys$count.x*100)

ys %>% ggplot() + geom_bar(aes(x=youngness,y=perc,fill=Sex),stat = "identity",
                           position = position_dodge())

## aloneornot-Sex surviving percentage
as1 <- train %>% group_by(aloneornot, Sex) %>% summarise(count=n())

as2 <- train %>% group_by(aloneornot, Sex, Survived) %>% 
  filter(Survived==1) %>% summarise(count=n())

as <- merge(as1,as2,by=c("aloneornot","Sex"),all=TRUE) 
as <- as %>% mutate(perc=as$count.y/as$count.x*100)

as %>% ggplot() + geom_bar(aes(x=aloneornot,y=perc,fill=Sex),stat = "identity",
                           position = position_dodge())

## aloneornot-Pclass surviving percentage
ac1 <- train %>% group_by(aloneornot, Pclass) %>% summarise(count=n())

ac2 <- train %>% group_by(aloneornot, Pclass, Survived) %>% 
  filter(Survived==1) %>% summarise(count=n())

ac <- merge(ac1,ac2,by=c("aloneornot","Pclass"),all=TRUE) 
ac <- ac %>% mutate(perc=ac$count.y/ac$count.x*100)

ac %>% ggplot() + geom_bar(aes(x=aloneornot,y=perc,fill=Pclass),stat = "identity",
                           position = position_dodge())

## Embarked surviving percentage
e1 <- train %>% group_by(Embarked) %>% summarise(count=n())
e2 <- train %>% group_by(Embarked, Survived) %>% 
  filter(Survived==1) %>% summarise(count=n())

e <- merge(e1,e2,by=c("Embarked"),all=TRUE) 
e <- e %>% mutate(perc=e$count.y/e$count.x*100)

e %>% ggplot() + geom_bar(aes(x=Embarked,y=perc,fill=perc),stat = "identity")

## Embarked-Pclass surviving percentage
ec1 <- train %>% group_by(Embarked, Pclass) %>% summarise(count=n())

ec2 <- train %>% group_by(Embarked, Pclass, Survived) %>% 
  filter(Survived==1) %>% summarise(count=n())

ec <- merge(ec1,ec2,by=c("Embarked","Pclass"),all=TRUE) 
ec <- ec %>% mutate(perc=ec$count.y/ec$count.x*100)

ec %>% ggplot() + geom_bar(aes(x=Embarked,y=perc,fill=Pclass),stat = "identity",
                           position = "dodge")

# Repeating same data cleaning for test data

## Exploring train data

summary(test)
colSums(is.na(test))

## Handling with missing data

test$Age[which(is.na(test$Age))] <- mean(test$Age,na.rm=TRUE)

## Adding new variables

test$aloneornot <- ifelse((test$SibSp<1 & test$Parch <1),0,1)

test$youngness <- ifelse((test$Age<18),"child",
                          ifelse((test$Age >= 18) & (test$Age < 40), 
                                 "young","old"))

## Removing unnecessary variables
colnames(test)
test <- test[,c(1,2,4,5,6,7,11,12,13)]

## Changing data types

str(test)

test$Pclass <- as.factor(test$Pclass)
test$aloneornot <- as.factor(test$aloneornot)
test$youngness <- as.factor(test$youngness)

# Machine Learning Algorithms

ranfor <- randomForest(formula = formula(Survived~Pclass+Sex+Age+Embarked+aloneornot),
                       data=train,ntree=1000)
plot(ranfor)
compare <- data.frame(Passenger=train$PassengerId,
                      actual=train$Survived,pred=ranfor$predicted)

test_pred <- predict(ranfor,test)
subm <- data.frame(PassengerId=test$PassengerId,
                   Survived=as.numeric(as.character(test_pred)))
write.csv(subm,"submission_random.csv",row.names = F)


