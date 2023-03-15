CREATE DATABASE [guitar shop];
USE [guitar shop];
CREATE TABLE Furnizor
(ID_F INT PRIMARY KEY IDENTITY,
nume VARCHAR(100),
adresa_depozit VARCHAR(100),
data_semnare_contract DATE,
data_expirare_contract DATE,
nume_produs VARCHAR(100)
);
CREATE TABLE Produs
(ID_P INT PRIMARY KEY IDENTITY,
ID_F INT FOREIGN KEY REFERENCES Furnizor(ID_F),
nume_produs VARCHAR(100),
categorie VARCHAR(100),
pret FLOAT,
stoc INT
); 
CREATE TABLE Client
(ID_Cl INT PRIMARY KEY IDENTITY,
nume_si_prenume VARCHAR(100),
adresa VARCHAR(200),
telefon INT
);
CREATE TABLE Transport
(ID_T INT PRIMARY KEY IDENTITY,
data_de_livrare DATE,
firma VARCHAR(100),
pret_livrare INT
);
CREATE TABLE Comanda
(ID_C INT PRIMARY KEY IDENTITY,
ID_Cl INT FOREIGN KEY REFERENCES Client(ID_Cl),
Metoda_de_plata VARCHAR(100),
ID_T INT FOREIGN KEY REFERENCES Transport(ID_T)
);
CREATE TABLE Achizitii
(ID_C INT FOREIGN KEY REFERENCES Comanda(ID_C),
ID_P INT FOREIGN KEY REFERENCES Produs(ID_P),
cantitate INT,
pretul_de_achizitie FLOAT,
CONSTRAINT pk_Achizitii PRIMARY KEY (ID_C, ID_P)
);
DROP DATABASE [guitar shop];


INSERT INTO Furnizor(nume,adresa_depozit,data_semnare_contract,data_expirare_contract)
VALUES
('Guitar storage','strada Lebedelor numarul 5','2019-10-10','2023-10-10')
SELECT *FROM Furnizor;
DELETE FROM Furnizor;
UPDATE Furnizor
SET adresa_depozit='STR MACULUI NR 10'
WHERE ID_F=1

INSERT INTO Produs(ID_F, nume_produs, categorie, pret, stoc)
VALUES
(1, 'Ibanez FR800', 'chitara electrica', '5200', 30),
(1, 'Fender', 'chitara acustica', '1600', 25),
(1, 'Dunlop whah', 'pedala', '970', 70),
(1, 'Fender ml45', 'chitara acustica', '550', 10)
SELECT *FROM Produs
DELETE FROM Produs
UPDATE Produs
SET categorie='CHITARA ELECTRICA' 
WHERE nume_produs = 'Fender' OR nume_produs = 'Fender ml45'


INSERT INTO Client(nume_si_prenume, adresa, telefon)
VALUES
('Popa Marian', 'Str Andrei Saguna nr 7', 0732452411),
('Stefan Darius', 'Str Orientului nr 10', 0744444346),
('Bobu Emanuel', 'Str Scoalei bl X26', 0751270723)
SELECT *FROM Client
DELETE FROM Client

INSERT INTO Transport(data_de_livrare, firma, pret_livrare)
VALUES
('2020-11-20', 'RPD-NAINTE', 10),
('2020-11-27', 'NEMO', 20),
('2020-11-25', 'SIMBA', 5),
('2020-11-24', 'NEMO', 3),
('2020-12-13', NULL, 10)
SELECT *FROM Transport
DELETE FROM Transport
UPDATE Transport
SET data_de_livrare = '2020-12-1'
WHERE ID_T >= 5
UPDATE Transport
SET pret_livrare = 15
WHERE firma <> 'NEMO'
UPDATE Transport
SET firma='MAINE EXP'
WHERE pret_livrare > 15
UPDATE Transport
SET firma = 'SIMBA'
WHERE pret_livrare < 4
DELETE FROM Transport
WHERE firma IS NULL
SELECT *FROM Transport 
WHERE NOT pret_livrare = 3

INSERT INTO Comanda(ID_Cl, Metoda_de_plata, ID_T)
VALUES
(1, 'Card',1),
(2, 'Card',2),
(3, 'Card',3)
SELECT *FROM Comanda
DELETE FROM Comanda

INSERT INTO Achizitii(ID_C, ID_P, cantitate, pretul_de_achizitie)
VALUES 
(1, 2, 1, '5200'),
(2, 3, 1, '1580'),
(3, 4, 2, '970')   
SELECT *FROM Achizitii
DELETE FROM Achizitii
WHERE [cantitate] = 1 AND ID_C = 2
UPDATE Achizitii
SET cantitate = 3 
WHERE pretul_de_achizitie <= 1000


SELECT nume_produs
FROM Produs
UNION
SELECT nume_si_prenume
FROM Client;

SELECT DISTINCT Metoda_de_plata
from Comanda;

select Produs.nume_produs, Produs.categorie, Produs.pret, Furnizor.adresa_depozit, Furnizor.data_semnare_contract
from Furnizor
FULL JOIN Produs
ON Furnizor.nume_produs=Produs.nume_produs;
 
select Produs.nume_produs,Produs.categorie , Produs.pret, Client.nume_si_prenume, Client.adresa
from Produs
INNER JOIN Client
ON Produs.nume_produs=Client.nume_si_prenume;

select Nr_produs_aceeasi_categorie=count(categorie), categorie
from Produs
GROUP BY categorie
HAVING count(categorie) > 1;

select sum(pret), nume_produs
from Produs
where pret<2000 or nume_produs='Ibanez FR800'
GROUP BY nume_produs
HAVING sum(pret)>500;

select pret=avg(pret), stoc=avg(stoc), nume_produs
from Produs
GROUP BY nume_produs;

select pret=avg(pret), stoc=avg(stoc), categorie
from Produs
GROUP BY categorie;


CREATE FUNCTION [dbo].[ExistaComanda]
(@New_ID_C INT, @New_ID_P INT, @New_pretul_de_achizitie INT)
RETURNS BIT AS
BEGIN 
IF (EXISTS(
SELECT ID_C FROM Achizitii
WHERE ID_C=@New_ID_C ))
AND
(EXISTS (
SELECT ID_P FROM Achizitii
WHERE ID_P=@New_ID_P ))
RETURN 1
RETURN 0
END

CREATE FUNCTION [dbo].[ExistaProdus]
(@GetName VARCHAR(100))
RETURNS VARCHAR(50)AS
BEGIN 
DECLARE @b1 VARCHAR(50) = 'Acest tip de produs exista deja'
DECLARE @b2 VARCHAR(50) = 'Acest tip de produs NU exista'
IF(EXISTS(
SELECT nume_produs FROM Produs
WHERE nume_produs=@GetName))
RETURN @b1
RETURN @b2
END


CREATE FUNCTION [dbo].[ValidateComanda]
(@ID_V INT)
RETURNS BIT AS
BEGIN
IF(EXISTS(
SELECT ID_C FROM Comanda
WHERE ID_C = @ID_V))
RETURN 1;
RETURN 0;
END

CREATE VIEW vw_Client
AS
SELECT c.nume_si_prenume, c.adresa, c.telefon, t.data_de_livrare 
FROM Client c
INNER JOIN Transport t
ON c.ID_Cl=t.ID_T;

SELECT * FROM vw_Client;


CREATE TRIGGER [dbo].[La_Introducere_Produs] ON [dbo].[Produs]
	AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @nume_produs VARCHAR, @data_ora DATETIME
	SELECT @nume_produs = INSERTED.nume_produs
	FROM INSERTED 
	
	PRINT(GETDATE())
	PRINT('insert'+' '+@nume_produs+' '+'From Produs')

END 

DROP TRIGGER La_Introducere_Produs;

CREATE TRIGGER [dbo].[La_Stergere_Produs] ON [dbo].[Produs]
	FOR DELETE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @nume_produs VARCHAR, @data_ora DATETIME
	SELECT @nume_produs = DELETED.nume_produs
	FROM DELETED 

	PRINT(GETDATE())
	PRINT('deleted'+' '+@nume_produs+' '+'From Produs')
END 


DROP TRIGGER La_Stergere_Produs;


INSERT INTO Produs(ID_F, nume_produs, categorie, pret, stoc)
VALUES
(1, 'Gibson LesPaul', 'chitara electrica', '4400', 20)

DELETE FROM Produs
WHERE nume_produs='Gibson LesPaul'

SELECT * FROM Produs

CREATE PROCEDURE [dbo].[AdaugaProdus2] 
@Getnume_produs VARCHAR(100), @Getcategorie VARCHAR(100), @Getpret FLOAT, @Getstoc INT
AS 
BEGIN 
IF(dbo.ExistaProdus(@Getnume_produs)='Acest produs Nu exista')
	INSERT INTO Produs (nume_produs, categorie, pret, stoc) VALUES (@Getnume_produs, @Getcategorie, @Getpret, @Getstoc)
ELSE PRINT 'EXISTA'
END

CREATE PROCEDURE [dbo].[AdaugaAchizitii]
@Inserted_ID_C INT, @Inserted_ID_P INT, @Inserted_pretul_de_achizitie INT
AS 
BEGIN 
IF(dbo.ExistaComanda(@Inserted_ID_C,@Inserted_ID_P,@Inserted_pretul_de_achizitie)=0)
	INSERT INTO Achizitii(ID_C,ID_P,pretul_de_achizitie) VALUES (@Inserted_ID_C, @Inserted_ID_P, @Inserted_pretul_de_achizitie)
ELSE PRINT 'Acest pret de achizitie este la fel'
END

CREATE PROCEDURE [dbo].[ComandaAdd]
(@ID_C INT, @NewMetoda_de_plata VARCHAR(50))
AS 
BEGIN
DECLARE @id INT 
IF(dbo.ValidateComanda(@ID_C)=0)
INSERT INTO Comanda(ID_C, Metoda_de_plata) 
VALUES (@ID_C, @NewMetoda_de_plata)
ELSE 
PRINT 'Acest mod de plata a fost deja ales'
END

EXECUTE [dbo].[AdaugaProdus2] 'Chitara incepatori','acustic',500, 22
EXECUTE [dbo].[AdaugaProdus2] 'fender telecaster','electric',5560, 3
EXECUTE [dbo].[AdaugaProdus2] 'Chapman guitars','electro-acustic',1200, 8
--TEST-- EXECUTE [dbo].[AdaugaProdus] 'Chapman guitars','electro-acustic',1200, 8
PRINT dbo.ExistaProdus('Chitara incepatori')
PRINT dbo.ExistaProdus('fender telecaster')

EXECUTE [dbo].[AdaugaAchizitii] 3,2,1
EXECUTE [dbo].[AdaugaAchizitii] 4,7,3
EXECUTE [dbo].[AdaugaAchizitii] 5,9,2
EXECUTE [dbo].[AdaugaAchizitii] 6,7,4
--TEST-- EXECUTE [dbo].[AdaugaAchizitii] 7,3,5
--PRINT dbo.ExistaComandaRea(5,9,3)
--PRINT dbo.ExistaComandaRea(7,7,3)



EXECUTE [dbo].[ComandaAdd] 3, 'Card'
--TEST -- EXECUTE [dbo].[ComandaAdd] 6, 'Cash'

SELECT * FROM Comanda;
SELECT * FROM Achizitii;
SELECT * FROM Produs;