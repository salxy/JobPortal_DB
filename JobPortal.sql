USE JobPortal;

IF OBJECT_ID('[dbo].[Searches]', 'U') IS NOT NULL
DROP TABLE [dbo].[Searches]
GO
IF OBJECT_ID('[dbo].[Applies]', 'U') IS NOT NULL
DROP TABLE [dbo].[Applies]
GO
IF OBJECT_ID('[dbo].[Located]', 'U') IS NOT NULL
DROP TABLE [dbo].[Located]
GO
IF OBJECT_ID('[dbo].[JobPost]', 'U') IS NOT NULL
DROP TABLE [dbo].[JobPost]
GO
IF OBJECT_ID('[dbo].[Recruiter]', 'U') IS NOT NULL
DROP TABLE [dbo].[Recruiter]
GO
IF OBJECT_ID('[dbo].[JobSeeker]', 'U') IS NOT NULL
DROP TABLE [dbo].[JobSeeker]
GO
IF OBJECT_ID('[dbo].[Company]', 'U') IS NOT NULL
DROP TABLE [dbo].[Company]
GO
IF OBJECT_ID('[dbo].[Account]', 'U') IS NOT NULL
DROP TABLE [dbo].[Account]
GO



CREATE TABLE Account(
    Username VARCHAR(50) NOT NULL UNIQUE,
    Pass VARCHAR(50) NOT NULL,
    Profile_pic IMAGE,
    Email VARCHAR(50) NOT NULL UNIQUE CHECK(Email like '%@%.%'),
    PRIMARY KEY(Username),
);

CREATE TABLE Company(
    User_id INT IDENTITY(1000, 1),
    Cname VARCHAR(50) NOT NULL UNIQUE,
    Email VARCHAR(50) NOT NULL UNIQUE,
    City VARCHAR(50),
    Country VARCHAR(50),
    Website VARCHAR(50),
    Username VARCHAR(50) UNIQUE,
    PRIMARY KEY(User_id),
    FOREIGN KEY(Username) REFERENCES Account(Username) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Located(
    Locations VARCHAR(50),
    Company_id INT,
    PRIMARY KEY(Locations, Company_id),
    FOREIGN KEY(Company_id) REFERENCES Company(User_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE JobSeeker(
    User_id INT IDENTITY(1000, 1),
    Fname VARCHAR(50),
    Lname VARCHAR(50),
    Email VARCHAR(50) NOT NULL UNIQUE,
    Phone_num VARCHAR(30) NOT NULL,
    Experience INT,
    Gender CHAR(1) CHECK(Gender IN ('M', 'F')),
    Age INT,
    Disability VARCHAR(50),
    Ssn INT,
    Additional_info VARCHAR(500),
    Job_title VARCHAR(50),
    About_you VARCHAR(500),
    Cv IMAGE,
    Username VARCHAR(50) UNIQUE,
    PRIMARY KEY(User_id),
    FOREIGN KEY(Username) REFERENCES Account(Username) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Recruiter(
    User_id INT NOT NULL,
    Fname VARCHAR(50) NOT NULL,
    Lname VARCHAR(50) NOT NULL,
    Phone_num VARCHAR(30) NOT NULL,
    Cname VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY(Lname, User_id),
    FOREIGN KEY(User_id) REFERENCES Company(User_id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE JobPost(
    Job_id INT IDENTITY(1000, 1),
    Job_title VARCHAR(50),
    Job_desc VARCHAR(500),
    Post_date DATE,
    Exp_years INT,
    Salary MONEY,
    Rname VARCHAR(50) NOT NULL,
    User_id INT NOT NULL,
    PRIMARY KEY(Job_id),
    FOREIGN KEY(Rname, User_id) REFERENCES Recruiter(Lname, User_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY(User_id) REFERENCES Company(User_id) ON DELETE NO ACTION ON UPDATE NO ACTION,
);


CREATE TABLE Applies(
    User_id INT NOT NULL,
    Job_id INT NOT NULL,
    PRIMARY KEY(User_id, Job_id),
    FOREIGN KEY(User_id) REFERENCES JobSeeker(User_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(Job_id) REFERENCES JobPost(Job_id) ON DELETE CASCADE ON UPDATE CASCADE,
);


CREATE TABLE Searches(
    User_id INT NOT NULL,
    Job_id INT NOT NULL,
    PRIMARY KEY(User_id, Job_id),
    FOREIGN KEY(User_id) REFERENCES JobSeeker(User_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(Job_id) REFERENCES JobPost(Job_id) ON DELETE CASCADE ON UPDATE CASCADE,
);

-- 1) when a job seeker signs up, create account
INSERT INTO Account(Username, Pass, Email) VALUES('sara.a', '22asdfghjk78', 'sara001@hotmail.com');

-- 2) to insert this account's info
INSERT INTO JobSeeker(Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Ssn, Additional_info, Job_title, About_you) 
VALUES('Sara', 'Ahmad', 'sara001@hotmail.com', '961 81 000 111', 0, 'F', 21, 'Blindness', 345223179, 
'Completely blind in my right eye, and partially blind in my left eye. My blindness does not prevent me from performing everyday 
tasks since I have adapted to me disability.', 'Musician', 'I play multiple musical instruments including pianos, guitars, and drums. I also have a fairly good voice.');

-- 3) use email since it is a unique attribute to retrieve username of said account
UPDATE JobSeeker
SET JobSeeker.Username =  Account.Username
FROM JobSeeker, Account
WHERE Account.Email=JobSeeker.Email;


-- 4) when a company signs up, create account
INSERT INTO Account(Username, Pass, Email) VALUES('Anghami', '29swjnd82', 'Info@Anghami.com');
INSERT INTO Account(Username, Pass, Email) VALUES('Spinneys', '3748sufb767', 'loyalty@spinneys-lebanon.com');

-- 5) insert account's info
INSERT INTO Company(Cname, Email, City, Country, Website)
VALUES('Anghami', 'Info@Anghami.com', 'Beirut', 'Lebanon', 'https://www.anghami.com');

-- 6) use email since it is a unique attribute to retrieve username of said account
UPDATE Company
SET Company.Username =  Account.Username
FROM Company, Account
WHERE Account.Email=Company.Email;

-- 5) repeated - insert account's info
INSERT INTO Company(Cname, Email, City, Country, Website)
VALUES('Spinneys', 'loyalty@spinneys-lebanon.com', 'Beirut', 'Lebanon', 'https://www.spinneyslebanon.com');

-- 6) repeated - use email since it is a unique attribute to retrieve username of said account
UPDATE Company
SET Company.Username =  Account.Username
FROM Company, Account
WHERE Account.Email=Company.Email;

-- 7) insert locations of said company
INSERT INTO Located(Locations, Company_id) VALUES('Beirut, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'Anghami'));
INSERT INTO Located(Locations, Company_id)  VALUES('Cairo, Egypt', (SELECT User_id FROM Company WHERE Company.Cname = 'Anghami'));
INSERT INTO Located(Locations, Company_id)  VALUES('Abu Dhabi, UAE', (SELECT User_id FROM Company WHERE Company.Cname = 'Anghami'));
INSERT INTO Located(Locations, Company_id)  VALUES('Riyadh, KSA', (SELECT User_id FROM Company WHERE Company.Cname = 'Anghami'));

INSERT INTO Located(Locations, Company_id)  VALUES('Beirut, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'Spinneys'));
INSERT INTO Located(Locations, Company_id)  VALUES('Mount Lebanon, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'Spinneys'));
INSERT INTO Located(Locations, Company_id)  VALUES('North Lebanon, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'Spinneys'));
INSERT INTO Located(Locations, Company_id)  VALUES('South Lebanon, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'Spinneys'));

-- 8) insert a recruiter
INSERT INTO Recruiter(Fname, Lname, Phone_num, Cname, User_id)
VALUES('Mohammad', 'Makkawi', '961 76 454 533', 'Anghami', (SELECT User_id FROM Company WHERE Company.Cname = 'Anghami'));

INSERT INTO Recruiter(Fname, Lname, Phone_num, Cname, User_id)
VALUES('Hala', 'Maroun', '961 3 123 321', 'Spinneys', (SELECT User_id FROM Company WHERE Company.Cname = 'Spinneys'));

-- 9) when applying to a job post
INSERT INTO JobPost(Job_title, Job_desc, Post_date, Exp_years, Salary, Rname, User_id)
VALUES('Cashier','A Cashier, or Retail Cashier, is responsible for processing cash, debit, 
credit and check transactions using a cash register or other point-of-sale system in a retail environment.
Their duties include balancing the cash register
, making change, recording purchases, processing returns and scanning items for sale.',	'2022-07-09',0,150.00,'Maroun',(SELECT User_id FROM Recruiter WHERE Recruiter.Lname = 'Maroun'));

-- 10) search for a company named Spinneys
SELECT Cname, Email, City, Country, Website
FROM Company
WHERE Cname = 'Spinneys';

-- 11) search for a job seeker named Sara Ahmad
SELECT Username, Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Additional_info, Ssn, Job_title, About_you, Cv
FROM JobSeeker
WHERE Fname = 'Sara' AND Lname = 'Ahmad';

-- 12) job seeker sara.a searches for a job post by company name -- Spinneys therefore all the results are added to Searches relation
SELECT Job_title, Job_desc, Post_date, Exp_years, Salary, Recruiter.Fname,  Recruiter.Lname, Recruiter.Cname
FROM JobPost, Recruiter
WHERE JobPost.User_id IN(
    SELECT User_id
    FROM Company
    WHERE Cname = 'Spinneys'
) AND Recruiter.User_id IN(
    SELECT User_id
    FROM Company
    WHERE Cname = 'Spinneys'
);
-- continue - insert user_id of username sara.a and job_id of all jobs she searched for using nested queries
INSERT INTO Searches(User_id, Job_id) 
VALUES((SELECT User_id FROM JobSeeker WHERE Username = 'sara.a'), 
(SELECT Job_id
FROM JobPost, Recruiter
WHERE JobPost.User_id IN(
    SELECT User_id
    FROM Company
    WHERE Cname = 'Spinneys'
) AND Recruiter.User_id IN(
    SELECT User_id
    FROM Company
    WHERE Cname = 'Spinneys'
)));

-- 13) search for companies by location -- Beirut
SELECT Cname, Email, City, Country, Website
FROM Company AS C, Located AS L
WHERE C.User_id = L.Company_id AND L.Locations = 'Beirut, Lebanon';

-- 14) job seeker with username sara.a applies for a job with job_id 1000
INSERT INTO Applies(User_id, Job_id) 
VALUES((SELECT User_id FROM JobSeeker WHERE Username = 'sara.a'), 1000);

-- 15) user tries to log into account, check if username and password exist
SELECT *
FROM Account
WHERE Username = 'sara.a' AND Pass = '22asdfghjk78';

-- 16) display all jobs a user with username sara.a has searched for
SELECT JobPost.Job_title, Job_desc, Post_date, Exp_years, Salary
FROM Searches, JobPost
WHERE Searches.User_id IN(
    SELECT User_id
    FROM JobSeeker
    WHERE Username = 'sara.a'
);

-- 17) search for all job seekers with disability = blind
SELECT Username, Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Additional_info, Ssn, Job_title, About_you, Cv
FROM JobSeeker
WHERE Disability LIKE '%blind%' OR Disability LIKE '%Blind%';

-- 18) search for all job seekers with job title musician
SELECT Username, Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Additional_info, Ssn, Job_title, About_you, Cv
FROM JobSeeker
WHERE Job_title LIKE '%Musician' OR Job_title LIKE '%musician%';


-- 19) filter  all job seekers with job title musician and experience at least 2 years
SELECT Username, Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Additional_info, Ssn, Job_title, About_you, Cv
FROM JobSeeker
WHERE (Job_title LIKE '%Musician' OR Job_title LIKE '%musician%') AND Experience >= 2;

-- 20) sort my company name a-z
SELECT Cname, Email, City, Country, Website
FROM Company
ORDER BY Cname ASC;

-- 21) delete a job seekers account with username salwa
DELETE FROM JobSeeker WHERE Username = 'salwa';
DELETE FROM Account WHERE Username = 'salwa';
