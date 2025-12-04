DROP TABLE IF EXISTS Laiko;
DROP TABLE IF EXISTS Egzaminas;
DROP TABLE IF EXISTS Lanko_dalyka;
DROP TABLE IF EXISTS Desto;
DROP TABLE IF EXISTS Dalykas;
DROP TABLE IF EXISTS Destytojas;
DROP TABLE IF EXISTS Studentas;
DROP TABLE IF EXISTS Grupe;
DROP TABLE IF EXISTS Studiju_programa;

CREATE TABLE Studiju_programa (
                                  Pavadinimas VARCHAR(100) PRIMARY KEY,
                                  Stojamasis_balas DECIMAL(4, 2) DEFAULT 5.00,
                                  Fakultetas VARCHAR(100) NOT NULL
);

CREATE TABLE Grupe (
                       Grupes_id INT PRIMARY KEY,
                       Grupes_nr INT NOT NULL,
                       Studiju_programa_pav VARCHAR(100) NOT NULL,
                       FOREIGN KEY (Studiju_programa_pav) REFERENCES Studiju_programa(Pavadinimas)
);

CREATE TABLE Studentas (
                           Studento_nr INT PRIMARY KEY,
                           Stojamasis_balas DECIMAL(4, 2),
                           Vardas VARCHAR(50),
                           Pavarde VARCHAR(50),
                           Miestas VARCHAR(50) DEFAULT 'Vilnius',
                           Gatve VARCHAR(100),
                           Namas VARCHAR(10),
                           Studiju_programa_pav VARCHAR(100) NOT NULL,
                           Grupes_numeris INT,
                           FOREIGN KEY (Studiju_programa_pav) REFERENCES Studiju_programa(Pavadinimas),
                           FOREIGN KEY (Grupes_numeris) REFERENCES Grupe(Grupes_id)
);

CREATE TABLE Destytojas (
                            Destytojo_nr INT PRIMARY KEY,
                            Vardas VARCHAR(50),
                            Pavarde VARCHAR(50),
                            Laipsnis VARCHAR(50),
                            Fakultetas VARCHAR(100) NOT NULL
);

CREATE TABLE Dalykas (
                         Pavadinimas VARCHAR(100) PRIMARY KEY,
                         Fakultetas VARCHAR(100) NOT NULL,
                         Reikalingas_laipsnis VARCHAR(50)
);

CREATE TABLE Desto (
                       Destytojo_nr INT,
                       Dalyko_pav VARCHAR(100),
                       PRIMARY KEY (Destytojo_nr, Dalyko_pav),
                       FOREIGN KEY (Destytojo_nr) REFERENCES Destytojas(Destytojo_nr),
                       FOREIGN KEY (Dalyko_pav) REFERENCES Dalykas(Pavadinimas)
);

CREATE TABLE Lanko_dalyka (
                              Studento_nr INT,
                              Dalyko_pav VARCHAR(100),
                              PRIMARY KEY (Studento_nr, Dalyko_pav),
                              FOREIGN KEY (Studento_nr) REFERENCES Studentas(Studento_nr),
                              FOREIGN KEY (Dalyko_pav) REFERENCES Dalykas(Pavadinimas)
);

CREATE TABLE Egzaminas (
                           Data DATE NOT NULL,
                           Dalykas VARCHAR(100) NOT NULL,
                           PRIMARY KEY (Data, Dalykas),
                           FOREIGN KEY (Dalykas) REFERENCES Dalykas(Pavadinimas)
);

CREATE TABLE Laiko (
                       Studento_nr INT,
                       Dalykas VARCHAR(100),
                       Data DATE NOT NULL,
                       Pazymys DECIMAL(4, 2),
                       PRIMARY KEY (Studento_nr, Dalykas, Data),
                       FOREIGN KEY (Studento_nr) REFERENCES Studentas(Studento_nr),
                       FOREIGN KEY (Data, Dalykas) REFERENCES Egzaminas(Data, Dalykas)
);

-- CHECK predikatai
ALTER TABLE Laiko ADD CONSTRAINT Check_pazymys CHECK (Pazymys BETWEEN 1 AND 10);
ALTER TABLE Destytojas ADD CONSTRAINT Check_laipsnis CHECK (Laipsnis IN ('Bakalauras','Magistrantas','Docentas','Daktaras','Profesorius'));
ALTER TABLE Grupe ADD CONSTRAINT Check_numeris CHECK (Grupes_nr > 0 AND Grupes_nr < 10000);

-- Indeksai
CREATE UNIQUE INDEX idx_grupe_nr_programa ON Grupe (Grupes_nr, Studiju_programa_pav);
CREATE INDEX idx_studiju_programa_fakultetas ON Studiju_programa (Fakultetas);

-- View
CREATE VIEW Studentu_egz_vidurkiai AS
SELECT S.Studento_nr, S.Vardas, S.Pavarde, SP.Pavadinimas AS Studiju_programa, AVG(L.Pazymys) AS Vidurkis
FROM Studentas S
         JOIN Studiju_programa SP ON S.Studiju_programa_pav = SP.Pavadinimas
         LEFT JOIN Laiko L ON S.Studento_nr = L.Studento_nr
GROUP BY S.Studento_nr, S.Vardas, S.Pavarde, SP.Pavadinimas;

-- Materialized view
CREATE MATERIALIZED VIEW Grupiu_stud_skaicius AS
SELECT G.Grupes_id, G.Grupes_nr, G.Studiju_programa_pav, COUNT(S.Studento_nr) AS Studentu_skaicius
FROM Grupe G
         LEFT JOIN Studentas S ON G.Grupes_id = S.Grupes_numeris
GROUP BY G.Grupes_id, G.Grupes_nr, G.Studiju_programa_pav;

-- Trigeriai
CREATE OR REPLACE FUNCTION tikrinti_stojamaji_bala()
RETURNS TRIGGER AS $$
DECLARE minimalus_balas DECIMAL(4, 2);
BEGIN
SELECT Stojamasis_balas INTO minimalus_balas FROM Studiju_programa WHERE Pavadinimas = NEW.Studiju_programa_pav;
IF NEW.Stojamasis_balas < minimalus_balas THEN
        RAISE EXCEPTION 'Studento stojamasis balas (%) per mažas programai "%" (reikalingas: %)', NEW.Stojamasis_balas, NEW.Studiju_programa_pav, minimalus_balas;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tikrinti_stojamaji_bala
    BEFORE INSERT OR UPDATE ON Studentas
                         FOR EACH ROW EXECUTE FUNCTION tikrinti_stojamaji_bala();

CREATE OR REPLACE FUNCTION tikrinti_destytoja_dalykui()
RETURNS TRIGGER AS $$
DECLARE destytojo_fakultetas VARCHAR(100);
DECLARE dalyko_fakultetas VARCHAR(100);
DECLARE destytojo_laipsnis VARCHAR(50);
DECLARE reikalingas_laipsnis VARCHAR(50);
BEGIN
SELECT Fakultetas, Laipsnis INTO destytojo_fakultetas, destytojo_laipsnis FROM Destytojas WHERE Destytojo_nr = NEW.Destytojo_nr;
SELECT Fakultetas, Reikalingas_laipsnis INTO dalyko_fakultetas, reikalingas_laipsnis FROM Dalykas WHERE Pavadinimas = NEW.Dalyko_pav;
IF destytojo_fakultetas IS DISTINCT FROM dalyko_fakultetas THEN
        RAISE EXCEPTION 'Dėstytojo fakultetas (%) nesutampa su dalyko fakultetu (%)', destytojo_fakultetas, dalyko_fakultetas;
END IF;
    IF reikalingas_laipsnis IS NOT NULL THEN
        IF destytojo_laipsnis = 'Bakalauras' AND reikalingas_laipsnis IN ('Magistrantas','Docentas','Daktaras','Profesorius') THEN
            RAISE EXCEPTION 'Dėstytojo laipsnis (%) nepakankamas dalykui "%" (reikalingas: %)', destytojo_laipsnis, NEW.Dalyko_pav, reikalingas_laipsnis;
END IF;
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tikrinti_destytoja_dalykui
    BEFORE INSERT OR UPDATE ON Desto
                         FOR EACH ROW EXECUTE FUNCTION tikrinti_destytoja_dalykui();
