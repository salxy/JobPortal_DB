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
    FOREIGN KEY(Rname, User_id) REFERENCES Recruiter(Lname, User_id),
    FOREIGN KEY(User_id) REFERENCES Company(User_id)
);


CREATE TABLE Applies(
    User_id INT NOT NULL,
    Job_id INT NOT NULL,
    PRIMARY KEY(User_id, Job_id),
    FOREIGN KEY(User_id) REFERENCES JobSeeker(User_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(Job_id) REFERENCES JobPost(Job_id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE Searches(
    User_id INT NOT NULL,
    Job_id INT NOT NULL,
    PRIMARY KEY(User_id, Job_id),
    FOREIGN KEY(User_id) REFERENCES JobSeeker(User_id)       ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(Job_id) REFERENCES JobPost(Job_id)          ON DELETE CASCADE ON UPDATE CASCADE
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
INSERT INTO Account(Username, Pass, Email) VALUES('Spinneys', '3748sufb767', 'loyalty@spinneys-lebanon.com');

-- 5) repeated - insert account's info
INSERT INTO Company(Cname, Email, City, Country, Website)
VALUES('Spinneys', 'loyalty@spinneys-lebanon.com', 'Beirut', 'Lebanon', 'https://www.spinneyslebanon.com');

-- 6) repeated - use email since it is a unique attribute to retrieve username of said account
UPDATE Company
SET Company.Username =  Account.Username
FROM Company, Account
WHERE Account.Email=Company.Email;

-- 7) insert locations of said company
INSERT INTO Located(Locations, Company_id)  VALUES('Beirut, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'Spinneys'));
INSERT INTO Located(Locations, Company_id)  VALUES('Mount Lebanon, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'Spinneys'));
INSERT INTO Located(Locations, Company_id)  VALUES('North Lebanon, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'Spinneys'));
INSERT INTO Located(Locations, Company_id)  VALUES('South Lebanon, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'Spinneys'));

-- 8) insert a recruiter
INSERT INTO Recruiter(Fname, Lname, Phone_num, Cname, User_id)
VALUES('Hala', 'Maroun', '961 3 123 321', 'Spinneys', (SELECT User_id FROM Company WHERE Company.Cname = 'Spinneys'));

-- 9) when posting to a job post
INSERT INTO JobPost(Job_title, Job_desc, Post_date, Exp_years, Salary, Rname, User_id)
VALUES('Cashier','A Cashier, or Retail Cashier, is responsible for processing cash, debit, 
credit and check transactions using a cash register or other point-of-sale system in a retail environment.
Their duties include balancing the cash register
, making change, recording purchases, processing returns and scanning items for sale.',	'2022-07-09',0,150.00,'Maroun',(SELECT User_id FROM Recruiter WHERE Recruiter.Lname = 'Maroun'));

-- 10) job seeker with username sara.a applies for a job with job_id 1000
INSERT INTO Applies(User_id, Job_id) 
VALUES((SELECT User_id FROM JobSeeker WHERE Username = 'sara.a'), 1000);

-- 11) job seeker with username sara.a applies for a job with job_id 1000
INSERT INTO Searches(User_id, Job_id) 
VALUES((SELECT User_id FROM JobSeeker WHERE Username = 'sara.a'), 1000);

-- populating (repeated queries)
INSERT INTO Account(Username, Pass, Email) VALUES('ahmadrz', 'ahmad1234', 'arezek@gmail.com');
INSERT INTO JobSeeker(Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Ssn, Additional_info, Job_title, About_you) 
VALUES('Ahmad', 'Rezek', 'arezek@gmail.com', '961 3 123 123', 0, 'M', 25, 'Paraplegic', 998765243, 
'Paralyzed from the waist down.', 'Cashier', 'Looking for a cashier job where i can work while in wheelchair all the time.');
UPDATE JobSeeker
SET JobSeeker.Username =  Account.Username
FROM JobSeeker, Account
WHERE Account.Email=JobSeeker.Email;

INSERT INTO Account(Username, Pass, Email) VALUES('salah23', 'Hmdsal99', 'salahhmd@hotmail.com');
INSERT INTO JobSeeker(Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Ssn, Additional_info, Job_title, About_you) 
VALUES('Salah', 'Hammoud', 'salahhmd@hotmail.com', '961 3 222 923', 1, 'M', 24, 'Deaf', 223451678, 
'Completely deaf in left ear and partial hearing in right ear.', 'Software developer', 'I have a degree in computer science, looking for a job position in software development.');
UPDATE JobSeeker
SET JobSeeker.Username =  Account.Username
FROM JobSeeker, Account
WHERE Account.Email=JobSeeker.Email;

INSERT INTO Account(Username, Pass, Email) VALUES('malakkh', 'Malkhaled88', 'malak88@hotmail.com');
INSERT INTO JobSeeker(Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Ssn, Additional_info, Job_title, About_you) 
VALUES('Malak', 'Khaled', 'malak88@hotmail.com', '961 71 320 256', 5, 'F', 34, 'Amputated legs', 092567388, 
'Amputated legs. I wear prosthetic legs.', 'Web developer', 'CS degree, looking for a job position in web development. I have been working in web development for 5 years in various companies.');
UPDATE JobSeeker
SET JobSeeker.Username =  Account.Username
FROM JobSeeker, Account
WHERE Account.Email=JobSeeker.Email;

INSERT INTO Account(Username, Pass, Email) VALUES('mariam22', 'MarKh123', 'mariam24@gmail.com');
INSERT INTO JobSeeker(Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Ssn, Additional_info, Job_title, About_you) 
VALUES('Mariam', 'Khoury', 'mariam24@gmail.com', '961 71 234 554', 0, 'F', 21, 'Autistic', 234564122, 
'Level 1 autism. introvert. slight problems with social skills.', 'Accounting', 'Just graduated university with accounting degree. Looking for a degree in accounting.');
UPDATE JobSeeker
SET JobSeeker.Username =  Account.Username
FROM JobSeeker, Account
WHERE Account.Email=JobSeeker.Email;
-------
INSERT INTO Account(Username, Pass, Email) VALUES('BeirutAI', 'sy162nst96', 'info@beirutai.com');
INSERT INTO Company(Cname, Email, City, Country, Website)
VALUES('BeirutAI', 'info@beirutai.com', 'Beirut', 'Lebanon', 'https://beirutai.org');
UPDATE Company
SET Company.Username =  Account.Username
FROM Company, Account
WHERE Account.Email=Company.Email;
INSERT INTO Located(Locations, Company_id) VALUES('Beirut, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'BeirutAI'));

INSERT INTO Account(Username, Pass, Email) VALUES('Anghami', '29swjnd82', 'Info@Anghami.com');
INSERT INTO Company(Cname, Email, City, Country, Website)
VALUES('Anghami', 'Info@Anghami.com', 'Beirut', 'Lebanon', 'https://www.anghami.com');
UPDATE Company
SET Company.Username =  Account.Username
FROM Company, Account
WHERE Account.Email=Company.Email;
INSERT INTO Located(Locations, Company_id) VALUES('Beirut, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'Anghami'));
INSERT INTO Located(Locations, Company_id)  VALUES('Cairo, Egypt', (SELECT User_id FROM Company WHERE Company.Cname = 'Anghami'));
INSERT INTO Located(Locations, Company_id)  VALUES('Abu Dhabi, UAE', (SELECT User_id FROM Company WHERE Company.Cname = 'Anghami'));
INSERT INTO Located(Locations, Company_id)  VALUES('Riyadh, KSA', (SELECT User_id FROM Company WHERE Company.Cname = 'Anghami'));

INSERT INTO Account(Username, Pass, Email) VALUES('H&M', 'abs2578hs', 'Info@hm.com');
INSERT INTO Company(Cname, Email, City, Country, Website)
VALUES('H&M', 'Info@hm.com', 'Beirut', 'Lebanon', 'https://www.hm.com/lb/');
UPDATE Company
SET Company.Username =  Account.Username
FROM Company, Account
WHERE Account.Email=Company.Email;
INSERT INTO Located(Locations, Company_id) VALUES('Beirut, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'H&M'));
INSERT INTO Located(Locations, Company_id) VALUES('Chouifat, Lebanon', (SELECT User_id FROM Company WHERE Company.Cname = 'H&M'));
-------
INSERT INTO Recruiter(Fname, Lname, Phone_num, Cname, User_id)
VALUES('Mohammad', 'Makkawi', '961 76 454 533', 'Anghami',(SELECT User_id FROM Company WHERE Company.Cname = 'Anghami'));

INSERT INTO Recruiter(Fname, Lname, Phone_num, Cname, User_id)
VALUES('Samar', 'Yousef', '961 81 223 332', 'BeirutAI', (SELECT User_id FROM Company WHERE Company.Cname = 'BeirutAI'));

INSERT INTO Recruiter(Fname, Lname, Phone_num, Cname, User_id)
VALUES('Zakat', 'Mekari', '961 81 009 288', 'H&M', (SELECT User_id FROM Company WHERE Company.Cname = 'H&M'));
-------
INSERT INTO JobPost(Job_title, Job_desc, Post_date, Exp_years, Salary, Rname, User_id)
VALUES('Web developer','design and build websites for clients.', '2022-05-06',2 ,1000.00,'Yousef',(SELECT User_id FROM Recruiter WHERE Recruiter.Lname = 'Yousef'));

INSERT INTO JobPost(Job_title, Job_desc, Post_date, Exp_years, Salary, Rname, User_id)
VALUES('Graphic designer','design ads and posters for BeirutAIs social media accounts.','2022-02-19',4,750.00,'Yousef',(SELECT User_id FROM Recruiter WHERE Recruiter.Lname = 'Yousef'));

INSERT INTO JobPost(Job_title, Job_desc, Post_date, Exp_years, Salary, Rname, User_id)
VALUES('Marketing position','Market BeirutAIs projects.','2022-03-22',1,499.00,'Yousef',(SELECT User_id FROM Recruiter WHERE Recruiter.Lname = 'Yousef'));

INSERT INTO JobPost(Job_title, Job_desc, Post_date, Exp_years, Salary, Rname, User_id)
VALUES('Marketing position','Market Anghamis projects.','2022-03-22',1,499.00,'Makkawi',(SELECT User_id FROM Recruiter WHERE Recruiter.Lname = 'Makkawi'));

INSERT INTO JobPost(Job_title, Job_desc, Post_date, Exp_years, Salary, Rname, User_id)
VALUES('Manager for Customer Service','Manage the customer service department in Spinneys.','2021-12-21',5, 899.00,'Maroun',(SELECT User_id FROM Recruiter WHERE Recruiter.Lname = 'Maroun'));

INSERT INTO JobPost(Job_title, Job_desc, Post_date, Exp_years, Salary, Rname, User_id)
VALUES('Cashier','A Cashier, or Retail Cashier, is responsible for processing cash, debit, 
credit and check transactions using a cash register or other point-of-sale system in a retail environment.', '2022-03-12',0,190.00,'Yousef',(SELECT User_id FROM Recruiter WHERE Recruiter.Lname = 'Yousef'));

INSERT INTO JobPost(Job_title, Job_desc, Post_date, Exp_years, Salary, Rname, User_id)
VALUES('Manager for Customer Service','Manage the customer service department in H&M.','2021-11-01',5, 950.00,'Mekari',(SELECT User_id FROM Recruiter WHERE Recruiter.Lname = 'Mekari'));

INSERT INTO JobPost(Job_title, Job_desc, Post_date, Exp_years, Salary, Rname, User_id)
VALUES('Cashier','A Cashier, or Retail Cashier, is responsible for processing cash, debit, 
credit and check transactions using a cash register or other point-of-sale system in a retail environment.', '2022-04-18',0,150.00,'Mekari',(SELECT User_id FROM Recruiter WHERE Recruiter.Lname = 'Mekari'));
------
INSERT INTO Searches(User_id, Job_id) 
VALUES((SELECT User_id FROM JobSeeker WHERE Username = 'malakkh'), 1001);
------
INSERT INTO Applies(User_id, Job_id) 
VALUES((SELECT User_id FROM JobSeeker WHERE Username = 'malakkh'), 1001);

-- 12) search for a company named Spinneys
SELECT Cname AS [Company Name], Email, City, Country, Website
FROM Company
WHERE Cname = 'Spinneys';

-- 13) search for a job seeker named Sara Ahmad
SELECT Username, Fname AS [First Name], Lname AS [Last Name], Email, Phone_num AS [Phone Number], 
Experience, Gender, Age, Disability, Additional_info AS [Additional Information], Ssn, Job_title AS [Job Title], About_you AS [About You], Cv
FROM JobSeeker
WHERE Fname = 'Sara' AND Lname = 'Ahmad';

-- 14) job seeker sara.a searches for a job post by company name -- Spinneys therefore all the results are added to Searches relation
SELECT DISTINCT Job_title AS [Job Title], Job_desc AS [Job Description], Post_date AS [Post Date], 
Exp_years AS [Years of Experience Required], Salary, Recruiter.Fname AS [Recruiter's First Name],  Recruiter.Lname AS [Recruiter's Last Name], 
Recruiter.Cname AS [Company Name]
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

-- 15) job seeker sara011 searches for a job post by job title cashier
SELECT DISTINCT Job_title AS [Job Title], Job_desc AS [Job Description], Post_date AS [Post Date], 
Exp_years AS [Years of Experience Required], Salary, Recruiter.Fname AS [Recruiter's First Name],  Recruiter.Lname AS [Recruiter's Last Name], 
Recruiter.Cname AS [Company Name]
FROM JobPost, Recruiter
WHERE (Job_title LIKE '%Cashier%' OR Job_desc LIKE '%cashier%') AND JobPost.User_id = Recruiter.User_id;

-- 16) search for companies by location -- Beirut
SELECT Cname AS [Company Name], Email, City, Country, Website
FROM Company AS C, Located AS L
WHERE C.User_id = L.Company_id AND L.Locations = 'Beirut, Lebanon';


-- 17) user tries to log into account, check if username and password exist
SELECT *
FROM Account
WHERE Username = 'sara.a' AND Pass = '22asdfghjk78';

-- 18) display all jobs a user with username sara.a has searched for
SELECT JobPost.Job_title AS [Job Title], Job_desc AS [Job Description], Post_date AS [Post Date], 
Exp_years AS [Years of Experience Required], Salary
FROM Searches, JobPost
WHERE Searches.User_id IN(
    SELECT User_id
    FROM JobSeeker
    WHERE Username = 'sara.a'
);

-- 20) search for all job seekers with disability = blind
SELECT Username, Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Additional_info, Ssn, Job_title, About_you, Cv
FROM JobSeeker
WHERE Disability LIKE '%blind%' OR Disability LIKE '%Blind%';

-- 21) search for all job seekers with job title musician
SELECT Username, Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Additional_info, Ssn, Job_title, About_you, Cv
FROM JobSeeker
WHERE Job_title LIKE '%Musician' OR Job_title LIKE '%musician%';


-- 22) filter  all job seekers with job title musician and experience at least 2 years
SELECT Username, Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Additional_info, Ssn, Job_title, About_you, Cv
FROM JobSeeker
WHERE (Job_title LIKE '%Musician' OR Job_title LIKE '%musician%') AND Experience >= 0;

-- 23) sort by company name a-z
SELECT Cname, Email, City, Country, Website
FROM Company
ORDER BY Cname ASC;

-- 24) order job posts by salary highest to lowest
SELECT JobPost.Job_title, Job_desc, Post_date, Exp_years, Salary
FROM JobPost
ORDER BY Salary Desc;

-- 25) order job posts by salary lowest to highest
SELECT JobPost.Job_title, Job_desc, Post_date, Exp_years, Salary
FROM JobPost
ORDER BY Salary Asc;

-- 26) sort job posts from newest to oldest
SELECT DISTINCT Job_title, Job_desc, Post_date, Exp_years, Salary, R.Fname,  R.Lname, R.Cname
FROM JobPost AS J, Recruiter AS R
WHERE J.User_id = R.User_id
ORDER BY Post_date DESC;

-- 27) display all jobs a user with username sara.a has applied to
SELECT JobPost.Job_title, Job_desc, Post_date, Exp_years, Salary
FROM Applies, JobPost
WHERE Applies.User_id IN(
    SELECT User_id
    FROM JobSeeker
    WHERE Username = 'mariam22'
);

-- 28) display all job posts
SELECT JobPost.Job_title, Job_desc, Post_date, Exp_years, Salary
FROM JobPost;

-- 29) display the number of job posts available
SELECT COUNT(Job_id) AS [Number of Available Jobs]
FROM JobPost;

-- 30) update username on job seeker's account (should be unique)
UPDATE Account
SET Username = 'sara011'
Where Username = 'sara.a';

UPDATE JobSeeker
SET Username = 'sara011'
Where Username = 'sara.a';

-- 31) update any other info (not pk or fk) in job seeker
UPDATE JobSeeker
SET Phone_num = '961 81 231 998'
Where Username = 'sara011';

-- 32) update username on company's account (should be unique)
UPDATE Account
SET Username = 'AnghamiPlus'
Where Username = 'Anghami';

UPDATE Company
SET Username = 'AnghamiPlus'
Where Username = 'Anghami';

-- 33) update salary on job post (same for any other info)
UPDATE JobPost
SET Salary = 2000
WHERE Job_id = 1000;



-- 34) delete a job seekers account with username salwa
--DELETE FROM JobSeeker WHERE Username = 'mariam22';
--DELETE FROM Account WHERE Username = 'mariam22';

-- 35) delete a company account with username H&M (first delete all job posts of h&m)
--DELETE FROM JobPost WHERE User_id IN( SELECT User_id FROM Company WHERE Cname = 'H&M');
--DELETE FROM JobSeeker WHERE Username = 'H&M';
--DELETE FROM Account WHERE Username = 'H&M';
