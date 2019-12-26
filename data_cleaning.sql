/* Loading csv file */

CREATE TABLE train (
	PassengerId serial,
	Survived int,
	Pclass int,
	Name varchar(100),
	Sex varchar(50),
	Age numeric,
	SibSp numeric,
	Parch numeric,
	Ticket varchar(100),
	Fare numeric,
	Cabin varchar(100),
	Embarked varchar(50)
)

CREATE TABLE test ( 
	PassengerId serial,
	Pclass int,
	Name varchar(100),
	Sex varchar(50),
	Age numeric,
	SibSp numeric,
	Parch numeric,
	Ticket varchar(100),
	Fare numeric,
	Cabin varchar(100),
	Embarked varchar(50)
)

COPY train(PassengerId,Survived,Pclass,Name,Sex,Age,SibSp,Parch,Ticket,Fare,Cabin,Embarked)
FROM 'C:\Users\CE-USER\Desktop\comp\titanic\train.csv' DELIMITERS ',' CSV HEADER;

COPY test(PassengerId,Pclass,Name,Sex,Age,SibSp,Parch,Ticket,Fare,Cabin,Embarked)
FROM 'C:\Users\CE-USER\Desktop\comp\titanic\test.csv' DELIMITERS ',' CSV HEADER;

/* Handling with missing values */

SELECT * FROM train;

SELECT count(*)
FROM train where age is NULL;

SELECT count(*)
FROM train where embarked is NULL;

SELECT count(*)
FROM train where cabin is NULL;

/* SELECT avg(age) from train; */

update train 
set age = (SELECT avg(age) from train)
where age is null;

update train 
set cabin = 'no registered'
where cabin is null;

select embarked, count(embarked) as mf
from train 
group by embarked;

update train
set embarked='S'
where embarked is null;

select * from train order by passengerid asc;

/* Adding new variables */

alter table train
add aloneornot int;

update train
set aloneornot = case when sibsp<1 and parch<1 then 0 else 1 end;

alter table train
add youngness varchar(100);

update train
set youngness = case when age<18 then 'child' when age>=18 and age<40 then 'young' else 'old' end;

/* Dropping unnecessary variables */

select * from train;

alter table train
drop column name, drop column ticket, drop column fare, drop column cabin;

/* Creating new dataset with grouping other variables */
/*Pclass-Sex surviving percentage*/
select sex, pclass, count(*) as count_survived
into cl1
from train
where survived=1
group by survived, sex, pclass
order by sex asc, pclass asc;

select * from cl1;

select sex, pclass, count(*) as count_total
into cl2
from train
group by sex, pclass
order by sex asc, pclass asc;

select * from cl2;

select cl1.sex,cl1.pclass,count_survived, count_total
into cl
from cl1
left join cl2 on cl1.sex=cl2.sex and cl1.pclass=cl2.pclass;

select * from cl;

alter table cl
alter column count_survived type numeric;

alter table cl
alter column count_total type numeric;

alter table cl
add perc numeric;

update cl
set perc = round((count_survived/count_total*100),2);

alter table cl
alter column pclass type char(10);

/* Exporting csv file */

copy cl to 'C:\Users\CE-USER\Desktop\comp\titanic\SQL\cl.csv' csv header;

/*Pclass-youngness surviving percentage*/

select pclass, youngness, count(*) as count_survived
into yp1
from train
where survived=1
group by survived, youngness, pclass
order by youngness asc, pclass asc;

select * from yp1;

select  pclass, youngness, count(*) as count_total
into yp2
from train
group by youngness, pclass
order by youngness asc, pclass asc;

select * from yp2;

select yp1.youngness,yp1.pclass,count_survived, count_total
into yp
from yp1
left join yp2 on yp1.youngness=yp2.youngness and yp1.pclass=yp2.pclass;

select * from yp;

alter table yp
alter column count_survived type numeric;

alter table yp
alter column count_total type numeric;

alter table yp
add perc numeric;

update yp
set perc = round((count_survived/count_total*100),2);

alter table yp
alter column pclass type char(10);

/* Exporting csv file */

copy yp to 'C:\Users\CE-USER\Desktop\comp\titanic\SQL\yp.csv' csv header;

/*aloneornot-Sex surviving percentage*/

select aloneornot, sex, count(*) as count_survived
into as1
from train
where survived=1
group by survived, aloneornot, sex
order by sex asc, aloneornot asc;

select * from as1;

select  aloneornot, sex, count(*) as count_total
into as2
from train
group by aloneornot, sex
order by sex asc, aloneornot asc;

select * from as2;

select as1.sex,as1.aloneornot,count_survived, count_total
into as3
from as1
left join as2 on as1.sex=as2.sex and as1.aloneornot=as2.aloneornot;

select * from as3;

alter table as3
alter column count_survived type numeric;

alter table as3
alter column count_total type numeric;

alter table as3
add perc numeric;

update as3
set perc = round((count_survived/count_total*100),2);

/* Exporting csv file */

copy as3 to 'C:\Users\CE-USER\Desktop\comp\titanic\SQL\as3.csv' csv header;

/* aloneornot-pclass surviving percentage */

select aloneornot, pclass, count(*) as count_survived
into ap1
from train
where survived=1
group by survived, aloneornot, pclass
order by pclass asc, aloneornot asc;

select * from ap1;

select  aloneornot, pclass, count(*) as count_total
into ap2
from train
group by aloneornot, pclass
order by pclass asc, aloneornot asc;

select * from ap2;

select ap1.pclass,ap1.aloneornot,count_survived, count_total
into ap
from ap1
left join ap2 on ap1.pclass=ap2.pclass and ap1.aloneornot=ap2.aloneornot;

select * from ap;

alter table ap
alter column count_survived type numeric;

alter table ap
alter column count_total type numeric;

alter table ap
add perc numeric;

update ap
set perc = round((count_survived/count_total*100),2);

/* Exporting csv file */

copy ap to 'C:\Users\CE-USER\Desktop\comp\titanic\SQL\ap.csv' csv header;

/* Embarked-Pclass surviving percentage */ 

select embarked, pclass, count(*) as count_survived
into ep1
from train
where survived=1
group by survived, embarked, pclass
order by pclass asc, embarked asc;

select * from ep1;

select  embarked, pclass, count(*) as count_total
into ep2
from train
group by embarked, pclass
order by pclass asc, embarked asc;

select * from ep2;

select ep1.pclass,ep1.embarked,count_survived, count_total
into ep
from ep1
left join ep2 on ep1.pclass=ep2.pclass and ep1.embarked=ep2.embarked;

select * from ep;

alter table ep
alter column count_survived type numeric;

alter table ep
alter column count_total type numeric;

alter table ep
add perc numeric;

update ep
set perc = round((count_survived/count_total*100),2);

/* Exporting csv file */

copy ep to 'C:\Users\CE-USER\Desktop\comp\titanic\SQL\ep.csv' csv header;
