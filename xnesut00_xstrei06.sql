DROP TABLE Person CASCADE CONSTRAINTS;
DROP TABLE Person_function CASCADE CONSTRAINTS;
DROP TABLE Function CASCADE CONSTRAINTS;
DROP TABLE Appointment CASCADE CONSTRAINTS;
DROP TABLE Bureau CASCADE CONSTRAINTS;
DROP TABLE Bureau_type CASCADE CONSTRAINTS;
DROP TABLE Relationship CASCADE CONSTRAINTS;
DROP TABLE Decree CASCADE CONSTRAINTS;
DROP TABLE Bachelor_studies CASCADE CONSTRAINTS;
DROP TABLE Bachelor_student CASCADE CONSTRAINTS;
DROP TABLE Post_grad_studies CASCADE CONSTRAINTS;
DROP TABLE Post_grad_student CASCADE CONSTRAINTS;
DROP TABLE Driving_courses CASCADE CONSTRAINTS;
DROP TABLE Driv_cours_student CASCADE CONSTRAINTS;


CREATE TABLE Person (
    Birth_number INTEGER PRIMARY KEY,
    Name_ VARCHAR(30) NOT NULL,
    Surname VARCHAR(30) NOT NULL,
    Sex VARCHAR(1) CHECK (Sex IN ('M', 'F')),
    Noble_title VARCHAR(30),
    CHECK  (Birth_number >= 100000000 AND mod(Birth_number,11)=0)
);

INSERT INTO Person
VALUES (0203071231, 'Jaroslav', 'Streit', 'M', null);
INSERT INTO Person
VALUES (0106122467, 'Matěj', 'Nesuta', 'M', 'Rytíř');
INSERT INTO Person
VALUES (9755165673, 'Lenka', 'Zouharová', 'F', 'Hraběnka');

CREATE TABLE Appointment (
    App_ID NUMBER(10) GENERATED AS IDENTITY (START WITH 1111 INCREMENT BY 1) PRIMARY KEY,
    Appointment VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO Appointment
VALUES (DEFAULT, 'Jmenovan prezidentem');
INSERT INTO Appointment
VALUES (DEFAULT, 'Prijat ve vyberovem rizeni');

CREATE TABLE Bureau_type (
    Type_ID NUMBER(10) GENERATED AS IDENTITY (START WITH 1111 INCREMENT BY 1) PRIMARY KEY,
    B_type VARCHAR(30) NOT NULL UNIQUE
);

INSERT INTO Bureau_type (B_type)
VALUES ('Mestsky urad');
INSERT INTO Bureau_type
VALUES (DEFAULT, 'Krajsky urad');

CREATE TABLE Bureau (
    Shortcut VARCHAR(10) PRIMARY KEY,
    Bureau_name VARCHAR(50) NOT NULL,
    B_type_ID NUMBER(10) NOT NULL,
    CONSTRAINT Bureau_ID FOREIGN KEY (B_type_ID) REFERENCES Bureau_type (Type_ID),
    Founded DATE DEFAULT SYSDATE,
    Closed DATE DEFAULT SYSDATE NULL,
    Deed_of_foundation INTEGER NOT NULL UNIQUE,
    Publication_date DATE DEFAULT SYSDATE,
    City VARCHAR(50) NOT NULL,
    Street VARCHAR(50) NOT NULL,
    House_number NUMBER(10) NOT NULL,
    Postal_code NUMBER(5) NOT NULL CHECK(Postal_code > 9999),
    -- pro jednoduchost uvazujeme, ze oblastni pusobnost se vztahuje na oblast, kde se urad nachazi (podle adresy)
    Area_of_operation VARCHAR(10) CHECK (Area_of_operation IN ('Království', 'Země', 'Kraj', 'Okres', 'Obec')),
    Superior_shortcut VARCHAR(10) NULL,
    CONSTRAINT Superior_b FOREIGN KEY (Superior_shortcut) REFERENCES Bureau(Shortcut),
    CONSTRAINT superior_shortcut_shortcut CHECK (Superior_shortcut <> Shortcut),
    CHECK (Founded < Closed),
    CHECK (Deed_of_foundation > 0)
);

INSERT INTO Bureau
VALUES('MUBl', 'Mestsky urad Blansko', 1111, '11-JAN-1998', NULL, 12345,
       '29-JAN-1998', 'Blansko', 'Hybesova', 69, 67801, 'Okres', NULL);
INSERT INTO Bureau
VALUES('MUBo', 'Mestsky urad Boskovice', 1111, '09-SEP-2000', NULL, 12346,
       DEFAULT, 'Boskovice', 'Janackova', 55, 67801, 'Obec', 'MUBl');
INSERT INTO Bureau
VALUES('KUPh', 'Krajsky urad Praha', 1112, '01-JAN-1993', NULL, 12347,
       DEFAULT, 'Praha', 'Ulice Vaclava Havla', 1, 10000, 'Kraj', NULL);

CREATE TABLE Function (
    Function_ID NUMBER(10) GENERATED AS IDENTITY (START WITH 1111 INCREMENT BY 1),
    Function_name VARCHAR(50)  NOT NULL,
    Function_code INTEGER NOT NULL,
    App_ID NUMBER (10),
    Function_length INTERVAL YEAR(4) TO MONTH DEFAULT INTERVAL '0000-00' YEAR TO MONTH,
    Superior_ID NUMBER(10) NULL,
    Establishment_date DATE DEFAULT SYSDATE,
    Cancellation_date DATE DEFAULT SYSDATE,
    F_bureau VARCHAR(10),
    CONSTRAINT Appointment_ID FOREIGN KEY (App_ID) REFERENCES Appointment(App_ID),
    CONSTRAINT Superior_f FOREIGN KEY (Superior_ID) REFERENCES Function(Function_ID),
    CONSTRAINT Function_ID UNIQUE (Function_ID),
    CONSTRAINT Bureau FOREIGN KEY (F_bureau) REFERENCES Bureau(Shortcut),
    CONSTRAINT func_in_bur UNIQUE (Function_code, F_bureau),
    CHECK (Function_code > 0)
);

INSERT INTO Function
VALUES(DEFAULT, 'Urednik', 1234, 1111, DEFAULT, NULL, DEFAULT, DEFAULT, 'MUBl');
INSERT INTO Function
VALUES(DEFAULT, 'Sekretarka', 1234, 1112, DEFAULT, 1111, DEFAULT, DEFAULT, 'MUBo');
INSERT INTO Function
VALUES(DEFAULT, 'Administrator systemu', 1357, 1111, DEFAULT, NULL, DEFAULT, DEFAULT, 'KUPh');

CREATE TABLE Person_function (
    Table_ID NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Function_ID NUMBER(10),
    Date_from DATE DEFAULT SYSDATE NOT NULL,
    Date_to DATE DEFAULT SYSDATE,
    Employee_order NUMBER(5) NOT NULL,
    End_reason VARCHAR(150),
    Birth_number INTEGER,
    CONSTRAINT VALID_INTERVAL CHECK (Date_to > Date_from),
    CONSTRAINT Person_ID FOREIGN KEY (Birth_number) REFERENCES Person (Birth_number),
    CONSTRAINT Func_ID FOREIGN KEY (Function_ID) REFERENCES Function (Function_ID)
);

INSERT INTO Person_function
VALUES(DEFAULT, 1111, '07-MAR-2019', DEFAULT, 7, 'Nikdo nevi', '0203071231');
INSERT INTO Person_function
VALUES(DEFAULT, 1112, '11-MAR-2012', DEFAULT, 3,
       'Nesplnovani pracovni doby, alkoholismus na pracovisti', '9755165673');
INSERT INTO Person_function
VALUES(DEFAULT, 1113, '21-JUN-2016', NULL, 2, NULL, '0106122467');

CREATE TABLE Relationship (
    relationship_id NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Person_1 INTEGER NOT NULL,
    Person_2 INTEGER NOT NULL,
    rel_type VARCHAR(20) CHECK (rel_type IN ('Family member', 'School', 'Work', 'Other')),
    rel_description VARCHAR(1000),
    CONSTRAINT Person_ID1 FOREIGN KEY (Person_1) REFERENCES Person (Birth_number),
    CONSTRAINT Person_ID2 FOREIGN KEY (Person_2) REFERENCES Person (Birth_number),
    constraint uq1 unique (person_1, person_2),
    CHECK (person_1 <> person_2)
);

INSERT INTO Relationship
VALUES(DEFAULT, '0203071231', '9755165673', 'Family member', 'Sestra');

CREATE TABLE Decree (
    Decree_ID INTEGER PRIMARY KEY,
    Date_of_decision DATE DEFAULT SYSDATE,
    Date_of_execution DATE DEFAULT SYSDATE,
    Decree VARCHAR(200) NOT NULL,
    Reasoning VARCHAR(1000) NOT NULL,
    Person_ID INTEGER,
    Bureau_shortcut VARCHAR(10),
    CONSTRAINT D_person FOREIGN KEY (Person_ID) REFERENCES Person (Birth_number),
    CONSTRAINT D_bureau FOREIGN KEY (Bureau_shortcut) REFERENCES Bureau (Shortcut),
    CHECK (Decree_ID > 0)
);

INSERT INTO Decree
VALUES(731476, DEFAULT, DEFAULT, 'Vydani ridicskeho prukazu',
       'Ridicsky prukaz vydan na zaklade plnohodnotneho splneni autoskoly.', '0203071231', 'MUBl');
INSERT INTO Decree
VALUES(731482, DEFAULT, DEFAULT, 'Vydani ridicskeho prukazu',
       'Ridicsky prukaz vydan na zaklade plnohodnotneho splneni autoskoly.', '0203071231', 'MUBl');

CREATE TABLE Bachelor_studies (
    Field_ID INTEGER PRIMARY KEY,
    Name_ VARCHAR(50) NOT NULL,
    S_bureau VARCHAR(10),
    CONSTRAINT B_bureau FOREIGN KEY (S_bureau) REFERENCES  Bureau (Shortcut),
    CHECK (Field_ID > 0)
);

INSERT INTO Bachelor_studies
VALUES(12, 'Manazerska Informatika', 'KUPh');
INSERT INTO Bachelor_studies
VALUES(16, 'Informacni technologie', 'KUPh');

CREATE TABLE Post_grad_studies (
    Field_ID INTEGER PRIMARY KEY,
    Name_ VARCHAR(50) NOT NULL,
    Type_ VARCHAR(25) NOT NULL CHECK (Type_ IN ('Postgraduate certificates', 'Postgraduate diplomas', 'Master''s degrees', 'Doctorates')),
    S_bureau VARCHAR(10),
    CONSTRAINT P_bureau FOREIGN KEY (S_bureau) REFERENCES  Bureau (Shortcut),
    CHECK (Field_ID > 0)
);

INSERT INTO Post_grad_studies
VALUES(102, 'Umela inteligence', 'Postgraduate diplomas', 'KUPh');
INSERT INTO Post_grad_studies
VALUES(103, 'Kyberbezpecnost', 'Postgraduate diplomas', 'MUBl');

CREATE TABLE Driving_courses(
    Driving_course_ID NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vehicle_type VARCHAR(20) NOT NULL CHECK (vehicle_type IN ('A','B','BE','CE','D', 'DE', 'T', 'Others')),
    course_description VARCHAR(500) NULL,
    S_bureau VARCHAR(10),
    CONSTRAINT Driving_course_bureau FOREIGN KEY (S_bureau) REFERENCES  Bureau (Shortcut)
);

INSERT INTO Driving_courses
VALUES(DEFAULT,'T', 'Autoskola specializovana na traktory a vozidla na stavbe.', 'MUBl');
INSERT INTO Driving_courses
VALUES(DEFAULT,'Others', 'Letecka skola.', 'MUBl');

CREATE TABLE Bachelor_student (
    Table_ID NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Date_from DATE DEFAULT SYSDATE,
    Date_to DATE DEFAULT SYSDATE NULL,
    Successful_end VARCHAR(3) CHECK (Successful_end IN ('YES', 'NO')) NULL,
    S_studies NUMBER(10),
    S_person INTEGER,
    CONSTRAINT Studies1 FOREIGN KEY (S_studies) REFERENCES  Bachelor_studies (Field_ID),
    CONSTRAINT Student1 FOREIGN KEY (S_person) REFERENCES  Person (Birth_number)
);

INSERT INTO Bachelor_student
VALUES(DEFAULT, '21-SEP-2021', NULL, NULL, 16, '0203071231');
INSERT INTO Bachelor_student
VALUES(DEFAULT, '18-SEP-2018', '29-JUN-2022', 'YES', 12, '9755165673');

CREATE TABLE Post_grad_student (
    Table_ID NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Date_from DATE DEFAULT SYSDATE,
    Date_to DATE DEFAULT SYSDATE,
    Successful_end VARCHAR(3) CHECK (Successful_end IN ('YES', 'NO')),
    S_studies NUMBER(10),
    S_person INTEGER,
    CONSTRAINT Studies2 FOREIGN KEY (S_studies) REFERENCES  Post_grad_studies (Field_ID),
    CONSTRAINT Student2 FOREIGN KEY (S_person) REFERENCES  Person (Birth_number)
);

INSERT INTO Post_grad_student
VALUES(DEFAULT, '23-SEP-2020', NULL, NULL, 103, '0106122467');

CREATE TABLE Driv_cours_student (
    Table_ID NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Date_from DATE DEFAULT SYSDATE,
    Date_to DATE DEFAULT SYSDATE,
    Successful_end VARCHAR(3) CHECK (Successful_end IN ('YES', 'NO')),
    S_studies NUMBER(10),
    S_person INTEGER,
    CONSTRAINT Studies3 FOREIGN KEY (S_studies) REFERENCES Driving_courses (Driving_course_ID),
    CONSTRAINT Student3 FOREIGN KEY (S_person) REFERENCES  Person (Birth_number)
);

INSERT INTO Driv_cours_student
VALUES(DEFAULT,'23-SEP-2020', NULL, NULL, 1, '0106122467');