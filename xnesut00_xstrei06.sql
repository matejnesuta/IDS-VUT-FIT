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

--create FUNCTION valid_birth_number(birth_number IN varchar(10), sex IN varchar(1) )   
-- RETURN number  
-- IS  
--     valid number;  
-- BEGIN  
--    IF REGEXP_LIKE(birth_number, '^[[:digit:]]{10}$')  THEN {
    
--       z:= x;  
--    } 
--    ELSIF REGEXP_LIKE(birth_number, '^[[:digit:]]{9}$')  THEN  {

--    }
--    ELSE  
--       z:= 0;  
--    END IF;  
  
--    RETURN z;  
-- END;   
-- BEGIN  


CREATE TABLE Person (
    Birth_number VARCHAR(11) PRIMARY KEY,
    Name_ VARCHAR(30) NOT NULL,
    Surname VARCHAR(30) NOT NULL,
    Sex VARCHAR(1) CHECK (Sex IN ('M', 'F')),
    Noble_title VARCHAR(30)
    CHECK ((LENGTH(Birth_number) = 11) AND ISDATE())
);

INSERT INTO Person
VALUES ('020307/1234', 'Jaroslav', 'Streit', 'M', null);

CREATE TABLE Appointment (
    App_ID NUMBER(10) GENERATED AS IDENTITY (START WITH 1111 INCREMENT BY 1) PRIMARY KEY,
    Appointment VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO Appointment
VALUES (DEFAULT, 'Jmenovan prezidentem');

CREATE TABLE Bureau_type (
    Type_ID NUMBER(10) GENERATED AS IDENTITY (START WITH 1111 INCREMENT BY 1) PRIMARY KEY,
    B_type VARCHAR(30) NOT NULL UNIQUE
);

INSERT INTO Bureau_type
VALUES (DEFAULT, 'Mestsky urad');

CREATE TABLE Bureau (
    Shortcut VARCHAR(10) PRIMARY KEY,
    Bureau_name VARCHAR(50) NOT NULL,
    B_type VARCHAR(20) NOT NULL,
    CONSTRAINT Bureau_ID FOREIGN KEY (B_type) REFERENCES Bureau_type (B_type),
    Founded DATE DEFAULT SYSDATE,
    Closed DATE DEFAULT SYSDATE,
    Deed_of_foundation NUMBER(10) NOT NULL UNIQUE,
    Publication_date DATE DEFAULT SYSDATE,
    City VARCHAR(50) NOT NULL,
    Street VARCHAR(50) NOT NULL,
    House_number NUMBER(10) NOT NULL,
    Postal_code NUMBER(5) NOT NULL CHECK(Postal_code > 9999),
    -- pro jednoduchost uvazujeme, ze oblastni pusobnost se vztahuje na oblast, kde se urad nachazi (podle adresy)
    Area_of_operation VARCHAR(10) CHECK (Area_of_operation IN ('Království', 'Země', 'Region', 'Okres', 'Obec')),
    Superior_shortcut VARCHAR(10) NULL,
    CONSTRAINT Superior_b FOREIGN KEY (Superior_shortcut) REFERENCES Bureau(Shortcut),
    CHECK (Superior_shortcut <> Shortcut),
    CHECK (Founded < Closed)
);

INSERT INTO Bureau
VALUES('MUBl', 'Mestsky urad Blansko', 'Mestsky urad', '11-JAN-2000', DEFAULT, 12345,
       DEFAULT, 'Blansko', 'Hybesova', 69, 67801, 'Okres', NULL);

INSERT INTO Bureau
VALUES('MUBo', 'Mestsky urad Boskovice', 'Mestsky urad', '11-JAN-2000', DEFAULT, 12346,
       DEFAULT, 'Boskovice', 'Janackova', 55, 67801, 'Obec', NULL);

CREATE TABLE Function (
    Function_ID NUMBER(10) GENERATED AS IDENTITY (START WITH 1111 INCREMENT BY 1),
    Function_name VARCHAR(30)  NOT NULL,
    Function_code NUMBER(10) NOT NULL,
    App_ID NUMBER(10),
    Function_length INTERVAL YEAR(4) TO MONTH DEFAULT INTERVAL '0000-00' YEAR TO MONTH,
    Superior_ID NUMBER(10) NULL,
    Establishment_date DATE DEFAULT SYSDATE,
    Cancellation_date DATE DEFAULT SYSDATE,
    F_bureau VARCHAR(10),
    CONSTRAINT Appointment_ID FOREIGN KEY (App_ID) REFERENCES Appointment(App_ID),
    CONSTRAINT Superior_f FOREIGN KEY (Superior_ID) REFERENCES Function(Function_ID),
    CONSTRAINT Function_ID UNIQUE (Function_ID),
    CONSTRAINT Bureau FOREIGN KEY (F_bureau) REFERENCES Bureau(Shortcut),
    constraint func_in_bur unique (Function_code, F_bureau)
);

INSERT INTO Function
VALUES(DEFAULT, 'Urednik', 1234, 1111, DEFAULT, null, DEFAULT, DEFAULT, 'MUBl');

INSERT INTO Function
VALUES(DEFAULT, 'Urednik', 1234, 1111, DEFAULT, null, DEFAULT, DEFAULT, 'MUBo');

CREATE TABLE Person_function (
    Table_ID NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Function_ID NUMBER(10),
    Date_from DATE DEFAULT SYSDATE NOT NULL,
    Date_to DATE DEFAULT SYSDATE NOT NULL,
    Employee_order NUMBER(5) NOT NULL,
    End_reason VARCHAR(150),
    Birth_number VARCHAR(11),
    CONSTRAINT VALID_INTERVAL CHECK (Date_to > Date_from),
    CONSTRAINT Person_ID FOREIGN KEY (Birth_number) REFERENCES Person (Birth_number),
    CONSTRAINT Func_ID FOREIGN KEY (Function_ID) REFERENCES Function (Function_ID)
);

INSERT INTO Person_function
VALUES(DEFAULT, 1111, '07-MAR-2005', DEFAULT, 7, 'Nikdo nevi', '020307/1234');

CREATE TABLE Relationship (
    relationship_id NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Person_1 VARCHAR(11) NOT NULL,
    Person_2 VARCHAR(11) NOT NULL,
    rel_type VARCHAR(20) CHECK (rel_type IN ('Family member', 'School', 'Work', 'Other')),
    rel_description VARCHAR(1000),
    CONSTRAINT Person_ID1 FOREIGN KEY (Person_1) REFERENCES Person (Birth_number),
    CONSTRAINT Person_ID2 FOREIGN KEY (Person_2) REFERENCES Person (Birth_number),
    constraint uq1 unique (person_1, person_2),
    CHECK (person_1 <> person_2)
);

CREATE TABLE Decree (
    Decree_ID NUMBER(10) PRIMARY KEY,
    Date_of_decision DATE DEFAULT SYSDATE,
    Date_of_execution DATE DEFAULT SYSDATE,
    Decree VARCHAR(200) NOT NULL,
    Reasoning VARCHAR(1000) NOT NULL,
    Person_ID VARCHAR(11),
    Bureau_shortcut VARCHAR(10),
    CONSTRAINT D_person FOREIGN KEY (Person_ID) REFERENCES Person (Birth_number),
    CONSTRAINT D_bureau FOREIGN KEY (Bureau_shortcut) REFERENCES Bureau (Shortcut)
);

CREATE TABLE Bachelor_studies (
    Field_ID NUMBER(10) PRIMARY KEY,
    Name_ VARCHAR(50) NOT NULL,
    S_bureau VARCHAR(10),
    CONSTRAINT B_bureau FOREIGN KEY (S_bureau) REFERENCES  Bureau (Shortcut)
);

CREATE TABLE Post_grad_studies (
    Field_ID NUMBER(10) PRIMARY KEY,
    Name_ VARCHAR(50) NOT NULL,
    Type_ VARCHAR(20) CHECK (Type_ IN ('Postgraduate certificates', 'Postgraduate diplomas', 'Master''s degrees', 'Doctorates')),
    S_bureau VARCHAR(10),
    CONSTRAINT P_bureau FOREIGN KEY (S_bureau) REFERENCES  Bureau (Shortcut)
);

CREATE TABLE Bachelor_student (
    Table_ID NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Date_from DATE DEFAULT SYSDATE,
    Date_to DATE DEFAULT SYSDATE,
    Successful_end VARCHAR(3) CHECK (Successful_end IN ('YES', 'NO')),
    S_studies NUMBER(10),
    S_person VARCHAR(11),
    CONSTRAINT Studies1 FOREIGN KEY (S_studies) REFERENCES  Bachelor_studies (Field_ID),
    CONSTRAINT Student1 FOREIGN KEY (S_person) REFERENCES  Person (Birth_number)
);

CREATE TABLE Post_grad_student (
    Table_ID NUMBER(10) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Date_from DATE DEFAULT SYSDATE,
    Date_to DATE DEFAULT SYSDATE,
    Successful_end VARCHAR(3) CHECK (Successful_end IN ('YES', 'NO')),
    S_studies NUMBER(10),
    S_person VARCHAR(11),
    CONSTRAINT Studies2 FOREIGN KEY (S_studies) REFERENCES  Post_grad_studies (Field_ID),
    CONSTRAINT Student2 FOREIGN KEY (S_person) REFERENCES  Person (Birth_number)
);
