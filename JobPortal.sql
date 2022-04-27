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

-- when a job seeker signs up, create account
INSERT INTO Account(Username, Pass, Email) VALUES('sara.a', '22asdfghjk78', 'sara001@hotmail.com');

-- to insert this account's info
INSERT INTO JobSeeker(Fname, Lname, Email, Phone_num, Experience, Gender, Age, Disability, Ssn, Additional_info, Job_title, About_you) 
VALUES('Sara', 'Ahmad', 'sara001@hotmail.com', '961 81 000 111', 0, 'F', 21, 'Blindness', 345223179, 
'Completely blind in my right eye, and partially blind in my left eye. My blindness does not prevent me from performing everyday 
tasks since I have adapted to me disability.', 'Musician', 'I play multiple musical instruments including pianos, guitars, and drums. I also have a fairly good voice.');

-- use email since it is a unique attribute to retrieve username of said account
UPDATE JobSeeker
SET JobSeeker.Username =  Account.Username
FROM JobSeeker, Account
WHERE Account.Email=JobSeeker.Email;


-- when a company signs up, create account
INSERT INTO Account(Username, Pass, Email) VALUES('Anghami', '29swjnd82', 'Info@Anghami.com');

-- insert account's info
INSERT INTO Company(Cname, Email, City, Country, Website)
VALUES('Anghami', 'Info@Anghami.com', 'Beirut', 'Lebanon', 'https://www.anghami.com');

-- use email since it is a unique attribute to retrieve username of said account
UPDATE Company
SET Company.Username =  Account.Username
FROM Company, Account
WHERE Account.Email=Company.Email;

