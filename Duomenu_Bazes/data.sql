-- Studijų programos
INSERT INTO Studiju_programa VALUES ('Informatika', 7.00, 'IF');
INSERT INTO Studiju_programa VALUES ('Programu_sistemos', 8.00, 'IF');
INSERT INTO Studiju_programa VALUES ('Matematika', 6.00, 'MF');

-- Grupės
INSERT INTO Grupe VALUES (101, 1, 'Informatika');
INSERT INTO Grupe VALUES (102, 2, 'Informatika');
INSERT INTO Grupe VALUES (201, 1, 'Programu_sistemos');
INSERT INTO Grupe VALUES (301, 1, 'Matematika');

-- Studentai
INSERT INTO Studentas VALUES (10001, 7.5, 'Jonas', 'Jonaitis', 'Vilnius', 'Gedimino pr.', '10', 'Informatika', 101);
INSERT INTO Studentas VALUES (10002, 8.3, 'Ieva', 'Petrauskaitė', 'Kaunas', 'Laisvės al.', '25A', 'Programu_sistemos', 201);
INSERT INTO Studentas VALUES (10003, 6.2, 'Mantas', 'Sakalauskas', 'Vilnius', 'Konstitucijos pr.', '1', 'Matematika', 301);

-- Dėstytojai
INSERT INTO Destytojas VALUES (5001, 'Rasa', 'Kazlauskaitė', 'Daktaras', 'IF');
INSERT INTO Destytojas VALUES (5002, 'Tomas', 'Binkis', 'Docentas', 'IF');
INSERT INTO Destytojas VALUES (5003, 'Aurelijus', 'Matulaitis', 'Profesorius', 'MF');

-- Dalykai
INSERT INTO Dalykas VALUES ('Duomenų bazės', 'IF', 'Docentas');
INSERT INTO Dalykas VALUES ('Algoritmai', 'IF', 'Magistrantas');
INSERT INTO Dalykas VALUES ('Tikimybių teorija', 'MF', NULL);

-- Dėstymas
INSERT INTO Desto VALUES (5002, 'Duomenų bazės');
INSERT INTO Desto VALUES (5001, 'Algoritmai');
INSERT INTO Desto VALUES (5003, 'Tikimybių teorija');

-- Lankomi dalykai
INSERT INTO Lanko_dalyka VALUES (10001, 'Duomenų bazės');
INSERT INTO Lanko_dalyka VALUES (10002, 'Algoritmai');
INSERT INTO Lanko_dalyka VALUES (10003, 'Tikimybių teorija');

-- Egzaminai
INSERT INTO Egzaminas VALUES ('2025-01-15', 'Duomenų bazės');
INSERT INTO Egzaminas VALUES ('2025-01-20', 'Algoritmai');
INSERT INTO Egzaminas VALUES ('2025-01-25', 'Tikimybių teorija');

-- Pažymiai
INSERT INTO Laiko VALUES (10001, 'Duomenų bazės', '2025-01-15', 9.0);
INSERT INTO Laiko VALUES (10002, 'Algoritmai', '2025-01-20', 7.5);
INSERT INTO Laiko VALUES (10003, 'Tikimybių teorija', '2025-01-25', 6.0);
