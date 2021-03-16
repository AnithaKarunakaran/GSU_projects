/* database for final project */
#drop database if exists CECS;

create database CECS;

use CECS;


# drop table conference;
create table conference (
Conference_id int primary key,
Title varchar(500),
Conference_Date datetime,
Conference_Time varchar(35),
Ticker varchar(10),
Company varchar(100),
Conference_Quarter varchar(10)
);

select count(*) from conference;
-- 235
SELECT * FROM cecs.conference where year(Conference_Date)="2020";


# drop table participant;
create table participant (
Participant_id int primary key,
Participant_name varchar(50),
Participant_type varchar(100),
Participant_Organization varchar(50)
);

SELECT count(*) FROM cecs.participant;
-- 1525

# drop table conference_participant;
create table conference_participant (
Conference_id int,
Participant_id int,
PRIMARY KEY (Conference_id, Participant_id),
FOREIGN KEY(Conference_id) REFERENCES conference(Conference_id),
FOREIGN KEY(Participant_id) REFERENCES participant(Participant_id)
);

SELECT count(*) FROM cecs.conference_participant;
-- 1525

# drop table speech;
create table speech (
Speech_id int primary key,
Conference_id int,
Participant_id int,
Section varchar(500),
Speech varchar(10000),
FOREIGN KEY(Conference_id) REFERENCES conference(Conference_id),
FOREIGN KEY(Participant_id) REFERENCES participant(Participant_id)
);

select count(*) from speech;
-- 15758


-- How many conference calls in your database occurred in 2020? (10 points)
SELECT count(*) FROM cecs.conference where year(Conference_Date)="2020";

-- Print their ticker name and date. (10 points)
select Ticker, Conference_Date from conference where year(Conference_Date)="2020";

-- Given a ticker name and a specific date, how many participants and who are them? (10 points) 
-- ticker name as "AAL" and date as "2020-10-22"
select c.Ticker,c.Conference_Date, count(Participant_id) 
from conference_participant as cp
inner join conference as c
using(Conference_id)
where c.Ticker="AAL" and Conference_Date="2020-10-22";


-- Among those participants, how many are company participants and how many are conference call participants? (10 points) 
-- select a.* from (
select a.Ticker, a.Conference_Date, count(a.Participant_Organization) as company_participants from (
select c.Ticker,c.Conference_Date, c.company,p.*
from conference_participant as cp
inner join conference as c
using(Conference_id)
inner join participant as p
using (Participant_id)
where c.Ticker="AAL" and c.Conference_Date="2020-10-22"
)a
where a.Participant_type NOT LIKE 'attendee';
-- OR a.Participant_Organization IS NULL AND a.Participant_Organization NOT LIKE '%_%'=' ';

-- select a.* from (
select a.Ticker, a.Conference_Date, count(a.Participant_Organization) as conference_participants from (
select c.Ticker,c.Conference_Date, c.company,p.*
from conference_participant as cp
inner join conference as c
using(Conference_id)
inner join participant as p
using (Participant_id)
where c.Ticker="AAL" and c.Conference_Date="2020-10-22"
)a
where a.Participant_type LIKE 'attendee';

-- Can you print his/her speech, given the name of this participants, along with the ticker name and date? (10 points)
-- given the name of a participant as "Mike Linenberg" or "Doug Parker "
select c.Ticker, c.Conference_Date, p.Participant_name, s.Section, s.Speech
from conference_participant as cp
inner join conference as c
using(Conference_id)
inner join participant as p
using (Participant_id)
inner join speech s
using (Conference_id,Participant_id)
where c.Ticker="AAL" and c.Conference_Date="2020-10-22" and p.Participant_name LIKE "Doug Parker ";
