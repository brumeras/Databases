-- ============================================
-- UNIVERSITETO DUOMENŲ BAZĖS SCHEMA
-- ============================================

-- Ištrinti esamas lenteles (jei egzistuoja)
DROP TABLE IF EXISTS Laiko CASCADE;
DROP TABLE IF EXISTS Lanko_dalyka CASCADE;
DROP TABLE IF EXISTS Desto CASCADE;
DROP TABLE IF EXISTS egzaminas CASCADE;
DROP TABLE IF EXISTS Dalykas CASCADE;
DROP TABLE IF EXISTS Destytojas CASCADE;
DROP TABLE IF EXISTS studentas CASCADE;
DROP TABLE IF EXISTS Grupe CASCADE;
DROP TABLE IF EXISTS Studiju_programa CASCADE;

-- Ištrinti view'sus ir materialized view'sus
DROP VIEW IF EXISTS Studentu_egz_vidurkiai CASCADE;
DROP VIEW IF EXISTS Probleminiai_studentai CASCADE;
DROP MATERIALIZED VIEW IF EXISTS Studiju_programu_statistika CASCADE;
DROP MATERIALIZED VIEW IF EXISTS Destytoju_darbo_kruvis CASCADE;

-- ============================================
-- LENTELIŲ KŪRIMAS
-- ============================================

-- Studijų programų lentelė
CREATE TABLE IF NOT EXISTS Studiju_programa (
                                                Pavadinimas VARCHAR(100) PRIMARY KEY,
    Stojamasis_balas DECIMAL(4, 2),
    Fakultetas VARCHAR(100) NOT NULL
    );

-- Grupių lentelė
CREATE TABLE IF NOT EXISTS Grupe (
                                     Grupes_id SERIAL PRIMARY KEY,
                                     Grupes_nr INT,
                                     Studiju_programa_pav VARCHAR(100) NOT NULL,
    FOREIGN KEY (Studiju_programa_pav) REFERENCES Studiju_programa(Pavadinimas)
    );

-- Studentų lentelė
CREATE TABLE IF NOT EXISTS studentas (
                                         Studento_nr SERIAL PRIMARY KEY,
                                         Stojamasis_balas DECIMAL(4, 2),
    Vardas VARCHAR(50),
    Pavarde VARCHAR(50),
    Miestas VARCHAR(50),
    Gatve VARCHAR(50),
    Namas VARCHAR(50),
    Studiju_programa_pav VARCHAR(100) NOT NULL,
    Grupes_numeris INT,
    FOREIGN KEY (Studiju_programa_pav) REFERENCES Studiju_programa(Pavadinimas),
    FOREIGN KEY (Grupes_numeris) REFERENCES Grupe(Grupes_id)
    );

-- Dėstytojų lentelė
CREATE TABLE IF NOT EXISTS Destytojas (
                                          Destytojo_nr SERIAL PRIMARY KEY,
                                          Vardas VARCHAR(50),
    Pavarde VARCHAR(50),
    Laipsnis VARCHAR(50),
    Fakultetas VARCHAR(100)
    );

-- Dalykų lentelė
CREATE TABLE IF NOT EXISTS Dalykas (
                                       Pavadinimas VARCHAR(100) PRIMARY KEY,
    Fakultetas VARCHAR(100),
    Reikalingas_laipsnis VARCHAR(100)
    );

-- Dėstymo ryšių lentelė
CREATE TABLE IF NOT EXISTS Desto (
                                     Destytojo_nr INT,
                                     Dalyko_pav VARCHAR(100),
    PRIMARY KEY (Destytojo_nr, Dalyko_pav),
    FOREIGN KEY (Destytojo_nr) REFERENCES Destytojas(Destytojo_nr),
    FOREIGN KEY (Dalyko_pav) REFERENCES Dalykas(Pavadinimas)
    );

-- Lankymų lentelė
CREATE TABLE IF NOT EXISTS Lanko_dalyka (
                                            Studento_nr INT,
                                            Dalyko_pav VARCHAR(100),
    PRIMARY KEY (Studento_nr, Dalyko_pav),
    FOREIGN KEY (Studento_nr) REFERENCES Studentas(Studento_nr),
    FOREIGN KEY (Dalyko_pav) REFERENCES Dalykas(Pavadinimas)
    );

-- Egzaminų lentelė
CREATE TABLE IF NOT EXISTS egzaminas (
                                         Data DATE NOT NULL,
                                         Dalykas VARCHAR(100) NOT NULL,
    PRIMARY KEY (Data, Dalykas),
    FOREIGN KEY (Dalykas) REFERENCES Dalykas(Pavadinimas)
    );

-- Egzaminų rezultatų lentelė
CREATE TABLE IF NOT EXISTS Laiko(
                                    Studento_nr INT,
                                    Dalykas VARCHAR(100),
    Data DATE NOT NULL,
    Pazymys DEC(4, 2),
    PRIMARY KEY (Studento_nr, Dalykas, Data),
    FOREIGN KEY (Studento_nr) REFERENCES Studentas(Studento_nr),
    FOREIGN KEY (Data, Dalykas) REFERENCES Egzaminas(Data, Dalykas)
    );

-- ============================================
-- APRIBOJIMAI (CONSTRAINTS)
-- ============================================

-- BETWEEN predikatas pažymiui (1-10)
ALTER TABLE Laiko
    ADD CONSTRAINT Check_pazymys
        CHECK (Pazymys BETWEEN 1 AND 10);

-- IN predikatas dėstytojo laipsniui
ALTER TABLE Destytojas
    ADD CONSTRAINT Check_laipsnis
        CHECK (Laipsnis IN ('Magistrantas', 'Docentas', 'Daktaras', 'Profesorius'));

-- LIKE predikatas studento vardui (negali prasidėti skaičiumi)
ALTER TABLE Studentas
    ADD CONSTRAINT Check_vardas
        CHECK (Vardas !~ '^[0-9]');

-- LIKE predikatas studento pavardei (negali prasidėti skaičiumi)
ALTER TABLE Studentas
    ADD CONSTRAINT Check_pavarde
        CHECK (Pavarde !~ '^[0-9]');

-- IS NOT NULL predikatas studijų programos fakultetui
ALTER TABLE Studiju_programa
    ADD CONSTRAINT Check_fakultetasstud
        CHECK (Fakultetas IS NOT NULL);

-- IS NOT NULL predikatas dėstytojo fakultetui
ALTER TABLE Destytojas
    ADD CONSTRAINT Check_fakultetasdes
        CHECK (Fakultetas IS NOT NULL);

-- IS NOT NULL predikatas dalyko fakultetui
ALTER TABLE Dalykas
    ADD CONSTRAINT Check_fakultetasdal
        CHECK (Fakultetas IS NOT NULL);

-- COMPARISON predikatas grupės numeriui
ALTER TABLE Grupe
    ADD CONSTRAINT Check_numeris
        CHECK (Grupes_nr < 10000);

-- ============================================
-- DEFAULT REIKŠMĖS
-- ============================================

ALTER TABLE Studiju_programa
    ALTER COLUMN Stojamasis_balas SET DEFAULT 5.00;

ALTER TABLE Studentas
    ALTER COLUMN Miestas SET DEFAULT 'Vilnius';

ALTER TABLE Destytojas
    ALTER COLUMN Laipsnis SET DEFAULT 'Bakalauras';

ALTER TABLE Egzaminas
    ALTER COLUMN Data SET DEFAULT CURRENT_DATE;

-- ============================================
-- INDEKSAI
-- ============================================

-- Unikalus indeksas studento vardui ir pavardei
CREATE UNIQUE INDEX indeksas_stud_var_pav
    ON Studentas (Vardas, Pavarde);

-- Unikalus indeksas grupės numeriui ir programai
CREATE UNIQUE INDEX indeksas_grupes_nr
    ON Grupe (Grupes_nr, Studiju_programa_pav);

-- Neunikalus indeksas studijų programos fakultetui
CREATE INDEX indeksas_stud_prog
    ON Studiju_programa (Fakultetas);

-- Neunikalus indeksas pažymiui
CREATE INDEX indeksas_pazymys
    ON Laiko (Pazymys);

-- ============================================
-- VIRTUALIOS LENTELĖS (VIEWS)
-- ============================================

-- Studentų egzaminų vidurkiai
CREATE VIEW Studentu_egz_vidurkiai AS
SELECT
    S.Studento_nr,
    S.Vardas,
    S.Pavarde,
    SP.Pavadinimas AS Studiju_programa,
    AVG(L.Pazymys) AS Vidurkis
FROM Studentas S
         JOIN Studiju_programa SP ON S.Studiju_programa_pav = SP.Pavadinimas
         LEFT JOIN Laiko L ON S.Studento_nr = L.Studento_nr
GROUP BY S.Studento_nr, S.Vardas, S.Pavarde, SP.Pavadinimas;

-- Probleminiai studentai (vidurkis < 5 arba 2+ neišlaikyti)
CREATE VIEW Probleminiai_studentai AS
SELECT
    S.Studento_nr,
    S.Vardas,
    S.Pavarde,
    S.Studiju_programa,
    S.Vidurkis,
    COUNT(CASE WHEN L.Pazymys < 5 THEN 1 END) AS Neislaikyti
FROM Studentu_egz_vidurkiai S
         LEFT JOIN Laiko L ON S.Studento_nr = L.Studento_nr
GROUP BY S.Studento_nr, S.Vardas, S.Pavarde, S.Studiju_programa, S.Vidurkis
HAVING S.Vidurkis < 5 OR COUNT(CASE WHEN L.Pazymys < 5 THEN 1 END) >= 2;

-- ============================================
-- MATERIALIZUOTOS LENTELĖS (MATERIALIZED VIEWS)
-- ============================================

-- Studijų programų statistika
CREATE MATERIALIZED VIEW Studiju_programu_statistika AS
SELECT
    SP.Pavadinimas AS Studiju_programa,
    COUNT(DISTINCT S.Studento_nr) AS Studentu_skaicius,
    ROUND(AVG(L.Pazymys), 2) AS Programos_vidurkis,
    COUNT(CASE WHEN L.Pazymys < 5 THEN 1 END) AS Neišlaikyti_egzaminai
FROM Studiju_programa SP
         LEFT JOIN Studentas S ON S.Studiju_programa_pav = SP.Pavadinimas
         LEFT JOIN Laiko L ON L.Studento_nr = S.Studento_nr
GROUP BY SP.Pavadinimas;

-- Dėstytojų darbo krūvis
CREATE MATERIALIZED VIEW Destytoju_darbo_kruvis AS
SELECT
    D.Destytojo_nr,
    D.Vardas,
    D.Pavarde,
    COUNT(DISTINCT DE.Dalyko_pav) AS Destomu_dalyku_sk,
    COUNT(DISTINCT LD.Studento_nr) AS Mokomu_studentu_sk
FROM Destytojas D
         LEFT JOIN Desto DE ON D.Destytojo_nr = DE.Destytojo_nr
         LEFT JOIN Lanko_dalyka LD ON DE.Dalyko_pav = LD.Dalyko_pav
GROUP BY D.Destytojo_nr;

-- ============================================
-- DALYKINĖS TAISYKLĖS / TRIGGERIAI
-- ============================================

-- 1. Studento stojamojo balo patikrinimas
CREATE OR REPLACE FUNCTION Tikrinti_stojamaji_bala()
RETURNS TRIGGER AS $$
DECLARE
minimalus_balas DECIMAL(4, 2);
BEGIN
SELECT Stojamasis_balas INTO minimalus_balas
FROM Studiju_programa
WHERE Pavadinimas = NEW.Studiju_programa_pav;

IF NEW.Stojamasis_balas < minimalus_balas THEN
        RAISE EXCEPTION 'studento stojamasis balas per mazas studiju programai';
RETURN NULL;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggeris_stojamajam
    BEFORE INSERT OR UPDATE ON Studentas
                         FOR EACH ROW
                         EXECUTE FUNCTION Tikrinti_stojamaji_bala();

-- 2. Dėstytojo ir dalyko fakulteto patikrinimas
CREATE OR REPLACE FUNCTION Tikrinti_fakulteta()
RETURNS TRIGGER AS $$
DECLARE
destytojo_fak VARCHAR(100);
    dalyko_fak VARCHAR(100);
BEGIN
SELECT Fakultetas INTO destytojo_fak
FROM Destytojas
WHERE Destytojo_nr = NEW.Destytojo_nr;

SELECT Fakultetas INTO dalyko_fak
FROM Dalykas
WHERE Pavadinimas = NEW.Dalyko_pav;

IF destytojo_fak IS DISTINCT FROM dalyko_fak THEN
        RAISE EXCEPTION 'skirtingi destytojo ir dalyko fakultetai';
RETURN NULL;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggeris_fakultetui
    BEFORE INSERT OR UPDATE ON Desto
                         FOR EACH ROW
                         EXECUTE FUNCTION Tikrinti_fakulteta();

-- 3. Studento ir grupės studijų programos patikrinimas
CREATE OR REPLACE FUNCTION Tikrinti_stud_prog()
RETURNS TRIGGER AS $$
DECLARE
grupes_programa VARCHAR(100);
BEGIN 
    IF NEW.Grupes_numeris IS NOT NULL THEN
SELECT Studiju_programa_pav INTO grupes_programa
FROM Grupe
WHERE Grupes_id = NEW.Grupes_numeris;

IF NEW.Studiju_programa_pav IS DISTINCT FROM grupes_programa THEN
            RAISE EXCEPTION 'grupes ir studento fakultetai nesutampa';
RETURN NULL;
END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggeris_studiju_prog
    BEFORE INSERT OR UPDATE OF Grupes_numeris ON Studentas
    FOR EACH ROW
    EXECUTE FUNCTION Tikrinti_stud_prog();

-- 4. Dėstytojo kvalifikacijos laipsnio patikrinimas
CREATE OR REPLACE FUNCTION Tikrinti_laipsni()
RETURNS TRIGGER AS $$
DECLARE
destytojo_laipsnis VARCHAR(100);
    reikalingas_laipsnis VARCHAR(100);
BEGIN
SELECT Laipsnis INTO destytojo_laipsnis
FROM Destytojas
WHERE Destytojo_nr = NEW.Destytojo_nr;

SELECT d.Reikalingas_laipsnis INTO reikalingas_laipsnis
FROM Dalykas d
WHERE d.Pavadinimas = NEW.Dalyko_pav;

IF destytojo_laipsnis IN ('Bakalauras') AND 
       reikalingas_laipsnis IN ('Magistrantas', 'Docentas', 'Daktaras', 'Profesorius') THEN
        RAISE EXCEPTION 'netinkamas destytojo kvalifikacijos laipsnis';
RETURN NULL;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggeris_laipsnis
    BEFORE INSERT OR UPDATE ON Desto
                         FOR EACH ROW
                         EXECUTE FUNCTION Tikrinti_laipsni();

-- ============================================
-- PABAIGA
-- ============================================

-- Atnaujinti materialized views
REFRESH MATERIALIZED VIEW Studiju_programu_statistika;
REFRESH MATERIALIZED VIEW Destytoju_darbo_kruvis;

-- Pranešimas apie sėkmingą sukūrimą
DO $$
BEGIN
    RAISE NOTICE 'Schema sėkmingai sukurta!';
    RAISE NOTICE 'Sukurtos lentelės: 9';
    RAISE NOTICE 'Sukurti view''ai: 2';
    RAISE NOTICE 'Sukurti materialized view''ai: 2';
    RAISE NOTICE 'Sukurti triggeriai: 4';
END $$;