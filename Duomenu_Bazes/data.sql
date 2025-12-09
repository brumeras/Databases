-- ============================================
-- UNIVERSITETO DUOMENŲ BAZĖS TESTAVIMO DUOMENYS
-- ============================================

-- Išvalyti esamus duomenis (jei reikia)
TRUNCATE TABLE Laiko CASCADE;
TRUNCATE TABLE Lanko_dalyka CASCADE;
TRUNCATE TABLE Desto CASCADE;
TRUNCATE TABLE Egzaminas CASCADE;
TRUNCATE TABLE Dalykas CASCADE;
TRUNCATE TABLE Destytojas CASCADE;
TRUNCATE TABLE Studentas CASCADE;
TRUNCATE TABLE Grupe CASCADE;
TRUNCATE TABLE Studiju_programa CASCADE;

-- ============================================
-- 1. STUDIJŲ PROGRAMOS
-- ============================================

INSERT INTO studiju_programa(Pavadinimas, Stojamasis_balas, Fakultetas)
VALUES
    ('Informatika', 5.5, 'Matematikos fakultetas'),
    ('Matematika', 5.0, 'Matematikos fakultetas'),
    ('Biologija', 5.0, 'Gyvybės mokslų fakultetas'),
    ('Fizika', 5.2, 'Fizikos fakultetas'),
    ('Chemija', 5.3, 'Chemijos fakultetas');

-- ============================================
-- 2. GRUPĖS
-- ============================================

INSERT INTO grupe (Grupes_nr, Studiju_programa_pav)
VALUES
    (1, 'Informatika'),
    (2, 'Informatika'),
    (3, 'Matematika'),
    (4, 'Biologija'),
    (5, 'Fizika'),
    (6, 'Chemija');

-- ============================================
-- 3. STUDENTAI
-- ============================================

INSERT INTO studentas (Stojamasis_balas, Vardas, Pavarde, Miestas, Gatve, Namas, Studiju_programa_pav, Grupes_numeris)
VALUES
    -- Informatikos studentai
    (6.0, 'Jonas', 'Jonaitis', 'Vilnius', 'Vilniaus g.', '12', 'Informatika', 1),
    (5.8, 'Asta', 'Astaitė', 'Kaunas', 'Kauno g.', '5', 'Informatika', 2),
    (7.2, 'Tomas', 'Tomaitis', 'Vilnius', 'Gedimino pr.', '25', 'Informatika', 1),
    (5.6, 'Laura', 'Lauraitė', 'Klaipėda', 'Jūros g.', '8', 'Informatika', 2),

    -- Matematikos studentai
    (5.2, 'Mantas', 'Mantaitis', 'Vilnius', 'Gedimino g.', '7', 'Matematika', 3),
    (6.8, 'Rūta', 'Rūtaitė', 'Šiauliai', 'Vilniaus g.', '15', 'Matematika', 3),
    (5.5, 'Darius', 'Dariūnas', 'Panevėžys', 'Laisvės a.', '33', 'Matematika', 3),

    -- Biologijos studentai
    (6.5, 'Eglė', 'Eglaitė', 'Kaunas', 'Laisvės pr.', '10', 'Biologija', 4),
    (5.9, 'Greta', 'Gretaitė', 'Vilnius', 'Partizanų g.', '42', 'Biologija', 4),

    -- Fizikos studentai
    (5.3, 'Povilas', 'Povilaitis', 'Alytus', 'Rotušės a.', '12', 'Fizika', 5),
    (6.1, 'Justė', 'Justaitė', 'Marijampolė', 'Parko g.', '7', 'Fizika', 5),

    -- Chemijos studentai
    (5.4, 'Mindaugas', 'Mindaugas', 'Utena', 'Utenio g.', '21', 'Chemija', 6),
    (6.7, 'Ieva', 'Ievaitė', 'Telšiai', 'Mažoji g.', '3', 'Chemija', 6);

-- ============================================
-- 4. DĖSTYTOJAI
-- ============================================

INSERT INTO destytojas (Vardas, Pavarde, Laipsnis, Fakultetas)
VALUES
    -- Fizikos fakulteto dėstytojai
    ('Petras', 'Petraitis', 'Docentas', 'Fizikos fakultetas'),
    ('Ona', 'Onaitė', 'Daktaras', 'Fizikos fakultetas'),

    -- Matematikos fakulteto dėstytojai
    ('Rasa', 'Rasaitė', 'Daktaras', 'Matematikos fakultetas'),
    ('Vytautas', 'Vytautaitis', 'Profesorius', 'Matematikos fakultetas'),
    ('Agnė', 'Agnaitė', 'Docentas', 'Matematikos fakultetas'),

    -- Gyvybės mokslų fakulteto dėstytojai
    ('Dainius', 'Dainiūtis', 'Magistrantas', 'Gyvybės mokslų fakultetas'),
    ('Kristina', 'Kristinaitė', 'Daktaras', 'Gyvybės mokslų fakultetas'),

    -- Chemijos fakulteto dėstytojai
    ('Valdas', 'Valdaitis', 'Profesorius', 'Chemijos fakultetas'),
    ('Jūratė', 'Jūraitė', 'Docentas', 'Chemijos fakultetas');

-- ============================================
-- 5. DALYKAI
-- ============================================

INSERT INTO dalykas (Pavadinimas, Fakultetas, Reikalingas_laipsnis)
VALUES
    -- Fizikos fakulteto dalykai
    ('Programavimas', 'Fizikos fakultetas', 'Docentas'),
    ('Duomenų struktūros', 'Fizikos fakultetas', 'Daktaras'),

    -- Matematikos fakulteto dalykai
    ('Algoritmai', 'Matematikos fakultetas', 'Daktaras'),
    ('Diskretinė matematika', 'Matematikos fakultetas', 'Profesorius'),
    ('Tikimybių teorija', 'Matematikos fakultetas', 'Docentas'),

    -- Gyvybės mokslų fakulteto dalykai
    ('Genetika', 'Gyvybės mokslų fakultetas', 'Magistrantas'),
    ('Molekulinė biologija', 'Gyvybės mokslų fakultetas', 'Daktaras'),

    -- Chemijos fakulteto dalykai
    ('Organinė chemija', 'Chemijos fakultetas', 'Profesorius'),
    ('Analitinė chemija', 'Chemijos fakultetas', 'Docentas');

-- ============================================
-- 6. EGZAMINAI
-- ============================================

INSERT INTO egzaminas (Data, Dalykas)
VALUES
    -- 2025 m. gruodžio egzaminai
    ('2025-12-01', 'Programavimas'),
    ('2025-12-02', 'Algoritmai'),
    ('2025-12-03', 'Genetika'),
    ('2025-12-05', 'Diskretinė matematika'),
    ('2025-12-08', 'Organinė chemija'),
    ('2025-12-10', 'Duomenų struktūros'),
    ('2025-12-12', 'Tikimybių teorija'),
    ('2025-12-15', 'Molekulinė biologija'),
    ('2025-12-18', 'Analitinė chemija'),

    -- 2026 m. sausio egzaminai (pakartotiniai)
    ('2026-01-15', 'Programavimas'),
    ('2026-01-16', 'Algoritmai'),
    ('2026-01-17', 'Genetika');

-- ============================================
-- 7. DĖSTYMO RYŠIAI
-- ============================================

INSERT INTO desto (Destytojo_nr, Dalyko_pav)
VALUES
    -- Fizikos fakultetas
    (1, 'Programavimas'),
    (2, 'Duomenų struktūros'),

    -- Matematikos fakultetas
    (3, 'Algoritmai'),
    (4, 'Diskretinė matematika'),
    (5, 'Tikimybių teorija'),

    -- Gyvybės mokslų fakultetas
    (6, 'Genetika'),
    (7, 'Molekulinė biologija'),

    -- Chemijos fakultetas
    (8, 'Organinė chemija'),
    (9, 'Analitinė chemija');

-- ============================================
-- 8. DALYKŲ LANKYMAS
-- ============================================

INSERT INTO lanko_dalyka (Studento_nr, Dalyko_pav)
VALUES
    -- Informatikos studentai
    (1, 'Programavimas'),
    (1, 'Algoritmai'),
    (1, 'Diskretinė matematika'),
    (2, 'Programavimas'),
    (2, 'Duomenų struktūros'),
    (3, 'Programavimas'),
    (3, 'Algoritmai'),
    (4, 'Programavimas'),
    (4, 'Duomenų struktūros'),

    -- Matematikos studentai
    (5, 'Algoritmai'),
    (5, 'Diskretinė matematika'),
    (5, 'Tikimybių teorija'),
    (6, 'Algoritmai'),
    (6, 'Tikimybių teorija'),
    (7, 'Diskretinė matematika'),
    (7, 'Tikimybių teorija'),

    -- Biologijos studentai
    (8, 'Genetika'),
    (8, 'Molekulinė biologija'),
    (9, 'Genetika'),
    (9, 'Molekulinė biologija'),

    -- Fizikos studentai (lanko ir matematikos dalykus)
    (10, 'Programavimas'),
    (10, 'Algoritmai'),
    (11, 'Duomenų struktūros'),
    (11, 'Tikimybių teorija'),

    -- Chemijos studentai
    (12, 'Organinė chemija'),
    (12, 'Analitinė chemija'),
    (13, 'Organinė chemija'),
    (13, 'Analitinė chemija');

-- ============================================
-- 9. EGZAMINŲ REZULTATAI
-- ============================================

INSERT INTO laiko (Studento_nr, Dalykas, Data, Pazymys)
VALUES
    -- Programavimo egzaminai
    (1, 'Programavimas', '2025-12-01', 8.5),
    (2, 'Programavimas', '2025-12-01', 4.0),  -- Neišlaikė
    (3, 'Programavimas', '2025-12-01', 9.2),
    (4, 'Programavimas', '2025-12-01', 7.5),
    (10, 'Programavimas', '2025-12-01', 6.8),

    -- Algoritmų egzaminai
    (1, 'Algoritmai', '2025-12-02', 7.0),
    (3, 'Algoritmai', '2025-12-02', 8.8),
    (5, 'Algoritmai', '2025-12-02', 9.0),
    (6, 'Algoritmai', '2025-12-02', 5.5),
    (10, 'Algoritmai', '2025-12-02', 4.5),  -- Neišlaikė

    -- Genetikos egzaminai
    (8, 'Genetika', '2025-12-03', 10.0),
    (9, 'Genetika', '2025-12-03', 7.8),

    -- Diskretinės matematikos egzaminai
    (1, 'Diskretinė matematika', '2025-12-05', 6.5),
    (5, 'Diskretinė matematika', '2025-12-05', 8.5),
    (7, 'Diskretinė matematika', '2025-12-05', 4.2),  -- Neišlaikė

    -- Organinės chemijos egzaminai
    (12, 'Organinė chemija', '2025-12-08', 7.5),
    (13, 'Organinė chemija', '2025-12-08', 9.5),

    -- Duomenų struktūrų egzaminai
    (2, 'Duomenų struktūros', '2025-12-10', 3.8),  -- Neišlaikė
    (4, 'Duomenų struktūros', '2025-12-10', 8.2),
    (11, 'Duomenų struktūros', '2025-12-10', 7.0),

    -- Tikimybių teorijos egzaminai
    (5, 'Tikimybių teorija', '2025-12-12', 9.5),
    (6, 'Tikimybių teorija', '2025-12-12', 6.8),
    (7, 'Tikimybių teorija', '2025-12-12', 4.0),  -- Neišlaikė (antrą kartą!)
    (11, 'Tikimybių teorija', '2025-12-12', 8.5),

    -- Molekulinės biologijos egzaminai
    (8, 'Molekulinė biologija', '2025-12-15', 9.8),
    (9, 'Molekulinė biologija', '2025-12-15', 8.5),

    -- Analitinės chemijos egzaminai
    (12, 'Analitinė chemija', '2025-12-18', 8.0),
    (13, 'Analitinė chemija', '2025-12-18', 10.0);

-- ============================================
-- 10. MATERIALIZED VIEWS ATNAUJINIMAS
-- ============================================

REFRESH MATERIALIZED VIEW Studiju_programu_statistika;
REFRESH MATERIALIZED VIEW Destytoju_darbo_kruvis;

-- ============================================
-- TESTAVIMO UŽKLAUSOS
-- ============================================

-- Patikrinti įvestus duomenis
SELECT 'Studijų programų skaičius: ' || COUNT(*) FROM studiju_programa;
SELECT 'Grupių skaičius: ' || COUNT(*) FROM grupe;
SELECT 'Studentų skaičius: ' || COUNT(*) FROM studentas;
SELECT 'Dėstytojų skaičius: ' || COUNT(*) FROM destytojas;
SELECT 'Dalykų skaičius: ' || COUNT(*) FROM dalykas;
SELECT 'Egzaminų skaičius: ' || COUNT(*) FROM egzaminas;
SELECT 'Dėstymo ryšių skaičius: ' || COUNT(*) FROM desto;
SELECT 'Lankymų skaičius: ' || COUNT(*) FROM lanko_dalyka;
SELECT 'Egzaminų rezultatų skaičius: ' || COUNT(*) FROM laiko;

-- Rodyti visų lentelių duomenis
SELECT '=== STUDIJŲ PROGRAMOS ===' AS info;
SELECT * FROM studiju_programa;

SELECT '=== GRUPĖS ===' AS info;
SELECT * FROM grupe;

SELECT '=== STUDENTAI ===' AS info;
SELECT * FROM studentas ORDER BY Studento_nr;

SELECT '=== DĖSTYTOJAI ===' AS info;
SELECT * FROM destytojas ORDER BY Destytojo_nr;

SELECT '=== DALYKAI ===' AS info;
SELECT * FROM dalykas;

SELECT '=== EGZAMINAI ===' AS info;
SELECT * FROM egzaminas ORDER BY Data;

SELECT '=== DĖSTYMO RYŠIAI ===' AS info;
SELECT * FROM desto;

SELECT '=== LANKYMAS ===' AS info;
SELECT * FROM lanko_dalyka ORDER BY Studento_nr;

SELECT '=== EGZAMINŲ REZULTATAI ===' AS info;
SELECT * FROM laiko ORDER BY Data, Studento_nr;

-- Rodyti view'sus
SELECT '=== STUDENTŲ VIDURKIAI ===' AS info;
SELECT * FROM Studentu_egz_vidurkiai ORDER BY Vidurkis DESC;

SELECT '=== PROBLEMINIAI STUDENTAI ===' AS info;
SELECT * FROM probleminiai_studentai;

SELECT '=== STUDIJŲ PROGRAMŲ STATISTIKA ===' AS info;
SELECT * FROM Studiju_programu_statistika;

SELECT '=== DĖSTYTOJŲ DARBO KRŪVIS ===' AS info;
SELECT * FROM Destytoju_darbo_kruvis ORDER BY Mokomu_studentu_sk DESC;

-- ============================================
-- TRIGGERIŲ TESTAVIMO SCENARIJAI (UŽKOMENTUOTI)
-- ============================================

-- Testas 1: Bandyti įvesti studentą su per mažu stojamojo balu
-- INSERT INTO studentas (Stojamasis_balas, Vardas, Pavarde, Studiju_programa_pav) 
-- VALUES (5.0, 'Testas', 'Testaitis', 'Informatika');
-- TIKIMASI: Klaida "studento stojamasis balas per mazas studiju programai"

-- Testas 2: Bandyti įvesti vardą prasidedantį skaičiumi
-- INSERT INTO studentas (Studento_nr, Vardas, Pavarde, Studiju_programa_pav) 
-- VALUES (301, '123Tomas', 'Tomauskas', 'Informatika');
-- TIKIMASI: Klaida dėl Check_vardas apribojimo

-- Testas 3: Bandyti įvesti per didelį grupės numerį
-- INSERT INTO Grupe (Grupes_id, Grupes_nr, Studiju_programa_pav) 
-- VALUES (201, 10000, 'Informatika');
-- TIKIMASI: Klaida dėl Check_numeris apribojimo

-- Testas 4: Bandyti priskirti studentą į kitą programą priklausančią grupę
-- INSERT INTO studentas (Studento_nr, Stojamasis_balas, Vardas, Pavarde, Studiju_programa_pav, Grupes_numeris) 
-- VALUES (400, 6.0, 'Andrius', 'Andriuka', 'Fizika', 1);
-- TIKIMASI: Klaida "grupes ir studento fakultetai nesutampa"

-- Testas 5: Bandyti priskirti dalyką dėstytojui iš kito fakulteto
-- INSERT INTO desto (Destytojo_nr, Dalyko_pav) 
-- VALUES (1, 'Algoritmai');
-- TIKIMASI: Klaida "skirtingi destytojo ir dalyko fakultetai"

-- Testas 6: Bandyti įvesti pažymį ne 1-10 intervale
-- INSERT INTO Laiko (Studento_nr, Dalykas, Data, Pazymys) 
-- VALUES (1, 'Programavimas', '2025-12-01', 12);
-- TIKIMASI: Klaida dėl Check_pazymys apribojimo

-- ============================================
-- PRANEŠIMAS APIE SĖKMINGĄ ĮKĖLIMĄ
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Duomenys sėkmingai įkelti!';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Įvestos studijų programos: 5';
    RAISE NOTICE 'Įvestos grupės: 6';
    RAISE NOTICE 'Įvesti studentai: 13';
    RAISE NOTICE 'Įvesti dėstytojai: 9';
    RAISE NOTICE 'Įvesti dalykai: 9';
    RAISE NOTICE 'Įvesti egzaminai: 12';
    RAISE NOTICE 'Įvesti egzaminų rezultatai: 28';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Yra problematiškų studentų:';
    RAISE NOTICE '  - Asta Astaitė (Informatika) - 2 neišlaikyti';
    RAISE NOTICE '  - Darius Dariūnas (Matematika) - 2 neišlaikyti';
    RAISE NOTICE '  - Povilas Povilaitis (Fizika) - 1 neišlaikytas';
    RAISE NOTICE '==============================================';
END $$;