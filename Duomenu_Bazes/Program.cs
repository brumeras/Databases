using System;
using System.Data;
using Npgsql;

// reikia update prideti 2

class Program
{
    static string connString = "Host=localhost;Port=5432;Database=universitetas;Username=semilija25;Password=";

    static void Main()
    {
        try
        {
            using var conn = new NpgsqlConnection(connString);
            conn.Open();
            Console.WriteLine("✓ Prisijungta prie duomenų bazės!");

            while (true)
            {
                Console.WriteLine("\n═══════════════════════════════════════");
                Console.WriteLine("       UNIVERSITETO VALDYMO SISTEMA");
                Console.WriteLine("═══════════════════════════════════════");
                Console.WriteLine("1.  Rodyti visus studentus");
                Console.WriteLine("2.  Ieškoti studento pagal vardą/pavardę");
                Console.WriteLine("3.  Rodyti studento informaciją su dalykais");
                Console.WriteLine("4.  Užregistruoti naują studentą");
                Console.WriteLine("5.  Perkelti studentą į kitą grupę (TRANSAKCIJA)");
                Console.WriteLine("6.  Pašalinti studentą iš sistemos (TRANSAKCIJA)");
                Console.WriteLine("7.  Rodyti studentų vidurkius (VIEW)");
                Console.WriteLine("8.  Rodyti problematiškus studentus");
                Console.WriteLine("9.  Įvesti egzamino pažymį studentui");
                Console.WriteLine("10. Rodyti studijų programų statistiką");
                Console.WriteLine("11. Rodyti dėstytojų darbo krūvį");
                Console.WriteLine("0.  Baigti darbą");
                Console.WriteLine("═══════════════════════════════════════");
                Console.Write("Pasirinkite veiksmą: ");
                
                var choice = Console.ReadLine();

                try
                {
                    switch (choice)
                    {
                        case "1": ShowAllStudents(conn); break;
                        case "2": SearchStudent(conn); break;
                        case "3": ShowStudentDetails(conn); break;
                        case "4": RegisterNewStudent(conn); break;
                        case "5": TransferStudentToGroup(conn); break;
                        case "6": RemoveStudent(conn); break;
                        case "7": ShowStudentAverages(conn); break;
                        case "8": ShowProblematicStudents(conn); break;
                        case "9": AddExamGrade(conn); break;
                        case "10": ShowProgramStatistics(conn); break;
                        case "11": ShowTeacherWorkload(conn); break;
                        case "0": 
                            Console.WriteLine("\nAčiū, kad naudojotės sistema!");
                            return;
                        default: 
                            Console.WriteLine("Neteisingas pasirinkimas. Bandykite dar kartą.");
                            break;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"\n✗ Klaida: {ex.Message}");
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"✗ Nepavyko prisijungti prie duomenų bazės: {ex.Message}");
        }
    }

    // 1. Duomenų paieška - rodyti visus studentus
    static void ShowAllStudents(NpgsqlConnection conn)
    {
        Console.WriteLine("\n--- VISI STUDENTAI ---");
        string sql = @"SELECT s.Studento_nr, s.Vardas, s.Pavarde, s.Studiju_programa_pav, 
                       s.Stojamasis_balas, g.Grupes_nr
                       FROM Studentas s
                       LEFT JOIN Grupe g ON s.Grupes_numeris = g.Grupes_id
                       ORDER BY s.Studento_nr";
        
        using var cmd = new NpgsqlCommand(sql, conn);
        using var reader = cmd.ExecuteReader();
        
        Console.WriteLine($"{"Nr",-5} {"Vardas",-15} {"Pavardė",-15} {"Programa",-20} {"Balas",-6} {"Grupė",-6}");
        Console.WriteLine(new string('-', 80));
        
        while (reader.Read())
        {
            int nr = reader.GetInt32(0);
            string vardas = reader.GetString(1);
            string pavarde = reader.GetString(2);
            string programa = reader.GetString(3);
            decimal balas = reader.GetDecimal(4);
            string grupe = reader.IsDBNull(5) ? "-" : reader.GetInt32(5).ToString();
            
            Console.WriteLine($"{nr,-5} {vardas,-15} {pavarde,-15} {programa,-20} {balas,-6:F2} {grupe,-6}");
        }
    }

    // 2. Duomenų paieška - ieškoti studento (naudoja LIKE)
    static void SearchStudent(NpgsqlConnection conn)
    {
        Console.WriteLine("\n--- STUDENTO PAIEŠKA ---");
        Console.Write("Įveskite studento vardą arba pavardę (arba jų dalį): ");
        string search = Console.ReadLine();
        
        string sql = @"SELECT s.Studento_nr, s.Vardas, s.Pavarde, s.Studiju_programa_pav, 
                       g.Grupes_nr, s.Miestas
                       FROM Studentas s
                       LEFT JOIN Grupe g ON s.Grupes_numeris = g.Grupes_id
                       WHERE LOWER(s.Vardas) LIKE LOWER(@search) 
                          OR LOWER(s.Pavarde) LIKE LOWER(@search)";
        
        using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("search", $"%{search}%");
        
        using var reader = cmd.ExecuteReader();
        bool found = false;
        
        while (reader.Read())
        {
            found = true;
            Console.WriteLine($"\nStudentas #{reader.GetInt32(0)}:");
            Console.WriteLine($"  Vardas: {reader.GetString(1)} {reader.GetString(2)}");
            Console.WriteLine($"  Programa: {reader.GetString(3)}");
            Console.WriteLine($"  Grupė: {(reader.IsDBNull(4) ? "nepriskirta" : reader.GetInt32(4).ToString())}");
            Console.WriteLine($"  Miestas: {reader.GetString(5)}");
        }
        
        if (!found)
            Console.WriteLine("Studentų nerasta.");
    }

    // 3. Duomenų paieška su JOIN - studento detalės su dalykais
    static void ShowStudentDetails(NpgsqlConnection conn)
    {
        Console.WriteLine("\n--- STUDENTO INFORMACIJA ---");
        Console.Write("Įveskite studento numerį: ");
        
        if (!int.TryParse(Console.ReadLine(), out int studentoNr))
        {
            Console.WriteLine("Neteisingas numeris.");
            return;
        }
        
        // Pagrindinė info
        string sql1 = @"SELECT s.Vardas, s.Pavarde, s.Studiju_programa_pav, s.Stojamasis_balas,
                        s.Miestas, s.Gatve, s.Namas, g.Grupes_nr
                        FROM Studentas s
                        LEFT JOIN Grupe g ON s.Grupes_numeris = g.Grupes_id
                        WHERE s.Studento_nr = @nr";
        
        using (var cmd = new NpgsqlCommand(sql1, conn))
        {
            cmd.Parameters.AddWithValue("nr", studentoNr);
            using var reader = cmd.ExecuteReader();
            
            if (!reader.Read())
            {
                Console.WriteLine("Studentas nerastas.");
                return;
            }
            
            Console.WriteLine($"\n{reader.GetString(0)} {reader.GetString(1)}");
            Console.WriteLine($"Programa: {reader.GetString(2)}");
            Console.WriteLine($"Stojamasis balas: {reader.GetDecimal(3):F2}");
            Console.WriteLine($"Adresas: {reader.GetString(4)}, {reader.GetString(5)} {reader.GetString(6)}");
            Console.WriteLine($"Grupė: {(reader.IsDBNull(7) ? "nepriskirta" : reader.GetInt32(7).ToString())}");
        }
        
        // Lankomų dalykų sąrašas
        string sql2 = @"SELECT d.Pavadinimas, d.Fakultetas, ds.Vardas, ds.Pavarde
                        FROM Lanko_dalyka ld
                        JOIN Dalykas d ON ld.Dalyko_pav = d.Pavadinimas
                        LEFT JOIN Desto de ON d.Pavadinimas = de.Dalyko_pav
                        LEFT JOIN Destytojas ds ON de.Destytojo_nr = ds.Destytojo_nr
                        WHERE ld.Studento_nr = @nr";
        
        using (var cmd = new NpgsqlCommand(sql2, conn))
        {
            cmd.Parameters.AddWithValue("nr", studentoNr);
            using var reader = cmd.ExecuteReader();
            
            Console.WriteLine("\nLankomi dalykai:");
            bool hasCourses = false;
            while (reader.Read())
            {
                hasCourses = true;
                string destytojas = reader.IsDBNull(2) ? "nėra dėstytojo" : 
                                   $"{reader.GetString(2)} {reader.GetString(3)}";
                Console.WriteLine($"  • {reader.GetString(0)} ({reader.GetString(1)}) - dėsto: {destytojas}");
            }
            if (!hasCourses)
                Console.WriteLine("  Studentas nelanko jokių dalykų.");
        }
        
        // Egzaminų rezultatai
        string sql3 = @"SELECT l.Dalykas, l.Data, l.Pazymys
                        FROM Laiko l
                        WHERE l.Studento_nr = @nr
                        ORDER BY l.Data DESC";
        
        using (var cmd = new NpgsqlCommand(sql3, conn))
        {
            cmd.Parameters.AddWithValue("nr", studentoNr);
            using var reader = cmd.ExecuteReader();
            
            Console.WriteLine("\nEgzaminų rezultatai:");
            bool hasExams = false;
            while (reader.Read())
            {
                hasExams = true;
                Console.WriteLine($"  • {reader.GetString(0)}: {reader.GetDecimal(2):F1} ({reader.GetDateTime(1):yyyy-MM-dd})");
            }
            if (!hasExams)
                Console.WriteLine("  Studentas dar nelaikė egzaminų.");
        }
    }

    // 4. Duomenų įvedimas - registruoti naują studentą
    static void RegisterNewStudent(NpgsqlConnection conn)
    {
        Console.WriteLine("\n--- NAUJO STUDENTO REGISTRACIJA ---");
        
        // Parodome esamas studijų programas
        Console.WriteLine("\nGalimos studijų programos:");
        string sqlProg = "SELECT Pavadinimas, Stojamasis_balas, Fakultetas FROM Studiju_programa";
        using (var cmd = new NpgsqlCommand(sqlProg, conn))
        using (var reader = cmd.ExecuteReader())
        {
            Console.WriteLine($"{"Pavadinimas",-20} {"Min. balas",-12} {"Fakultetas"}");
            Console.WriteLine(new string('-', 60));
            while (reader.Read())
            {
                Console.WriteLine($"{reader.GetString(0),-20} {reader.GetDecimal(1),-12:F2} {reader.GetString(2)}");
            }
        }
        
        Console.Write("\nVardas: ");
        string vardas = Console.ReadLine();
        
        Console.Write("Pavardė: ");
        string pavarde = Console.ReadLine();
        
        Console.Write("Studijų programos pavadinimas: ");
        string programa = Console.ReadLine();
        
        Console.Write("Stojamasis balas: ");
        if (!decimal.TryParse(Console.ReadLine(), out decimal balas))
        {
            Console.WriteLine("Neteisingas balas.");
            return;
        }
        
        Console.Write("Miestas (Enter - Vilnius): ");
        string miestas = Console.ReadLine();
        if (string.IsNullOrWhiteSpace(miestas)) miestas = "Vilnius";
        
        Console.Write("Gatvė: ");
        string gatve = Console.ReadLine();
        
        Console.Write("Namo numeris: ");
        string namas = Console.ReadLine();
        
        // Parodome galimas grupes
        Console.WriteLine($"\nGalimos grupės programai '{programa}':");
        string sqlGrupe = @"SELECT Grupes_id, Grupes_nr FROM Grupe 
                           WHERE Studiju_programa_pav = @prog";
        using (var cmd = new NpgsqlCommand(sqlGrupe, conn))
        {
            cmd.Parameters.AddWithValue("prog", programa);
            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                Console.WriteLine($"  ID: {reader.GetInt32(0)}, Grupės nr: {reader.GetInt32(1)}");
            }
        }
        
        Console.Write("Grupės ID (Enter - praleisti): ");
        string grupeInput = Console.ReadLine();
        int? grupeId = string.IsNullOrWhiteSpace(grupeInput) ? null : int.Parse(grupeInput);
        
        // Įrašome studentą
        string sql = @"INSERT INTO Studentas 
                      (Vardas, Pavarde, Studiju_programa_pav, Stojamasis_balas, 
                       Miestas, Gatve, Namas, Grupes_numeris)
                      VALUES (@vardas, @pavarde, @prog, @balas, @miestas, @gatve, @namas, @grupe)
                      RETURNING Studento_nr";
        
        try
        {
            using var cmd = new NpgsqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("vardas", vardas);
            cmd.Parameters.AddWithValue("pavarde", pavarde);
            cmd.Parameters.AddWithValue("prog", programa);
            cmd.Parameters.AddWithValue("balas", balas);
            cmd.Parameters.AddWithValue("miestas", miestas);
            cmd.Parameters.AddWithValue("gatve", gatve);
            cmd.Parameters.AddWithValue("namas", namas);
            cmd.Parameters.AddWithValue("grupe", grupeId.HasValue ? (object)grupeId.Value : DBNull.Value);
            
            int newId = (int)cmd.ExecuteScalar();
            Console.WriteLine($"\n✓ Studentas sėkmingai užregistruotas! Studento numeris: {newId}");
        }
        catch (PostgresException ex)
        {
            if (ex.Message.Contains("per mazas"))
                Console.WriteLine($"\n✗ Klaida: Stojamasis balas per mažas šiai programai!");
            else if (ex.Message.Contains("nesutampa"))
                Console.WriteLine($"\n✗ Klaida: Grupė nepriklauso pasirinktai programai!");
            else
                Console.WriteLine($"\n✗ Klaida: {ex.Message}");
        }
    }

    // 5. Duomenų atnaujinimas - perkelti studentą į kitą grupę (TRANSAKCIJA)
    static void TransferStudentToGroup(NpgsqlConnection conn)
    {
        Console.WriteLine("\n--- STUDENTO PERKĖLIMAS Į KITĄ GRUPĘ ---");
        
        Console.Write("Įveskite studento numerį: ");
        if (!int.TryParse(Console.ReadLine(), out int studentoNr))
        {
            Console.WriteLine("Neteisingas numeris.");
            return;
        }
        
        // Parodome studento dabartinę informaciją
        string sqlCurrent = @"SELECT s.Vardas, s.Pavarde, s.Studiju_programa_pav, g.Grupes_nr
                             FROM Studentas s
                             LEFT JOIN Grupe g ON s.Grupes_numeris = g.Grupes_id
                             WHERE s.Studento_nr = @nr";
        
        string programaPav;
        using (var cmd = new NpgsqlCommand(sqlCurrent, conn))
        {
            cmd.Parameters.AddWithValue("nr", studentoNr);
            using var reader = cmd.ExecuteReader();
            
            if (!reader.Read())
            {
                Console.WriteLine("Studentas nerastas.");
                return;
            }
            
            Console.WriteLine($"\nStudentas: {reader.GetString(0)} {reader.GetString(1)}");
            programaPav = reader.GetString(2);
            Console.WriteLine($"Programa: {programaPav}");
            Console.WriteLine($"Dabartinė grupė: {(reader.IsDBNull(3) ? "nepriskirta" : reader.GetInt32(3).ToString())}");
        }
        
        // Parodome galimas grupes
        Console.WriteLine($"\nGalimos grupės:");
        string sqlGrupes = @"SELECT Grupes_id, Grupes_nr FROM Grupe 
                            WHERE Studiju_programa_pav = @prog";
        using (var cmd = new NpgsqlCommand(sqlGrupes, conn))
        {
            cmd.Parameters.AddWithValue("prog", programaPav);
            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                Console.WriteLine($"  ID: {reader.GetInt32(0)}, Grupės nr: {reader.GetInt32(1)}");
            }
        }
        
        Console.Write("\nĮveskite naujos grupės ID: ");
        if (!int.TryParse(Console.ReadLine(), out int newGrupeId))
        {
            Console.WriteLine("Neteisingas ID.");
            return;
        }
        
        // TRANSAKCIJA
        using var tx = conn.BeginTransaction();
        try
        {   // nereikia, nes darom update, turi grazinti, ar pakeite viena eilute
            // ar ivyko sekmingai
            // is duomenu bazes suprasti
            // is griztamojo rysio, o ne selecto
            // suprasti, kad ivyko 
            // turi sudaryti insertas, delete... tik ne select
            
            // Patikriname ar grupė egzistuoja
            string sqlCheck = "SELECT COUNT(*) FROM Grupe WHERE Grupes_id = @gid AND Studiju_programa_pav = @prog";
            using (var cmd = new NpgsqlCommand(sqlCheck, conn, tx))
            {
                cmd.Parameters.AddWithValue("gid", newGrupeId);
                cmd.Parameters.AddWithValue("prog", programaPav);
                long count = (long)cmd.ExecuteScalar();
                
                if (count == 0)
                {
                    Console.WriteLine("Grupė nerasta arba nepriklauso studento programai.");
                    tx.Rollback();
                    return;
                }
            }
            
            // Atnaujiname studento grupę
            string sqlUpdate = "UPDATE Studentas SET Grupes_numeris = @gid WHERE Studento_nr = @nr";
            using (var cmd = new NpgsqlCommand(sqlUpdate, conn, tx))
            {
                cmd.Parameters.AddWithValue("gid", newGrupeId);
                cmd.Parameters.AddWithValue("nr", studentoNr);
                cmd.ExecuteNonQuery();
            }
            
            tx.Commit();
            Console.WriteLine("\n✓ Studentas sėkmingai perkeltas į naują grupę!");
        }
        catch (Exception ex)
        {
            tx.Rollback();
            Console.WriteLine($"\n✗ Klaida perkėlimo metu: {ex.Message}");
        }
    }
    
    // reikia sutvarkyti irgi
    // 6. Duomenų trynimas - pašalinti studentą (TRANSAKCIJA su keliais DELETE)
    static void RemoveStudent(NpgsqlConnection conn)
    {
        Console.WriteLine("\n--- STUDENTO PAŠALINIMAS IŠ SISTEMOS ---");
        
        Console.Write("Įveskite studento numerį: ");
        if (!int.TryParse(Console.ReadLine(), out int studentoNr))
        {
            Console.WriteLine("Neteisingas numeris.");
            return;
        }
        
        // Parodome studento informaciją
        string sqlInfo = "SELECT Vardas, Pavarde, Studiju_programa_pav FROM Studentas WHERE Studento_nr = @nr";
        using (var cmd = new NpgsqlCommand(sqlInfo, conn))
        {
            cmd.Parameters.AddWithValue("nr", studentoNr);
            using var reader = cmd.ExecuteReader();
            
            if (!reader.Read())
            {
                Console.WriteLine("Studentas nerastas.");
                return;
            }
            
            Console.WriteLine($"\nRastas studentas: {reader.GetString(0)} {reader.GetString(1)}");
            Console.WriteLine($"Programa: {reader.GetString(2)}");
        }
        
        Console.Write("\nAr tikrai norite pašalinti šį studentą? (taip/ne): ");
        string confirm = Console.ReadLine()?.ToLower();
        
        if (confirm != "taip")
        {
            Console.WriteLine("Operacija atšaukta.");
            return;
        }
        
        // TRANSAKCIJA - trinti iš visų susijusių lentelių
        using var tx = conn.BeginTransaction();
        try
        {
            // 1. Trinti iš Laiko (egzaminų rezultatai)
            using (var cmd = new NpgsqlCommand("DELETE FROM Laiko WHERE Studento_nr = @nr", conn, tx))
            {
                cmd.Parameters.AddWithValue("nr", studentoNr);
                int deleted = cmd.ExecuteNonQuery();
                Console.WriteLine($"  Ištrinti {deleted} egzaminų rezultatai.");
            }
            
            // 2. Trinti iš Lanko_dalyka (lankomi dalykai)
            using (var cmd = new NpgsqlCommand("DELETE FROM Lanko_dalyka WHERE Studento_nr = @nr", conn, tx))
            {
                cmd.Parameters.AddWithValue("nr", studentoNr);
                int deleted = cmd.ExecuteNonQuery();
                Console.WriteLine($"  Atsieti {deleted} dalykai.");
            }
            
            // 3. Trinti studentą
            using (var cmd = new NpgsqlCommand("DELETE FROM Studentas WHERE Studento_nr = @nr", conn, tx))
            {
                cmd.Parameters.AddWithValue("nr", studentoNr);
                int deleted = cmd.ExecuteNonQuery();
                
                if (deleted == 0)
                {
                    Console.WriteLine("Studentas nebuvo ištrintas.");
                    tx.Rollback();
                    return;
                }
            }
            
            tx.Commit();
            Console.WriteLine("\n✓ Studentas sėkmingai pašalintas iš sistemos!");
        }
        catch (Exception ex)
        {
            tx.Rollback();
            Console.WriteLine($"\n✗ Klaida šalinant studentą: {ex.Message}");
        }
    }

    // 7. VIEW - studento vidurkiai
    static void ShowStudentAverages(NpgsqlConnection conn)
    {
        Console.WriteLine("\n--- STUDENTŲ EGZAMINŲ VIDURKIAI ---");
        
        string sql = @"SELECT Studento_nr, Vardas, Pavarde, Studiju_programa, 
                       COALESCE(Vidurkis, 0) as Vidurkis
                       FROM Studentu_egz_vidurkiai
                       ORDER BY Vidurkis DESC";
        
        using var cmd = new NpgsqlCommand(sql, conn);
        using var reader = cmd.ExecuteReader();
        
        Console.WriteLine($"{"Nr",-5} {"Vardas",-15} {"Pavardė",-15} {"Programa",-20} {"Vidurkis"}");
        Console.WriteLine(new string('-', 75));
        
        while (reader.Read())
        {
            Console.WriteLine($"{reader.GetInt32(0),-5} {reader.GetString(1),-15} {reader.GetString(2),-15} " +
                            $"{reader.GetString(3),-20} {reader.GetDouble(4):F2}");
        }
    }

    // 8. VIEW - problemiški studentai
    static void ShowProblematicStudents(NpgsqlConnection conn)
    {
        Console.WriteLine("\n--- PROBLEMIŠKI STUDENTAI ---");
        Console.WriteLine("(Vidurkis < 5 arba 2+ neišlaikyti egzaminai)\n");
        
        string sql = "SELECT * FROM Probleminiai_studentai ORDER BY Vidurkis";
        
        using var cmd = new NpgsqlCommand(sql, conn);
        using var reader = cmd.ExecuteReader();
        
        if (!reader.HasRows)
        {
            Console.WriteLine("Probleminių studentų nėra. Puiku!");
            return;
        }
        
        Console.WriteLine($"{"Nr",-5} {"Vardas",-15} {"Pavardė",-15} {"Vidurkis",-10} {"Neišlaikyta"}");
        Console.WriteLine(new string('-', 70));
        
        while (reader.Read())
        {
            Console.WriteLine($"{reader.GetInt32(0),-5} {reader.GetString(1),-15} {reader.GetString(2),-15} " +
                            $"{reader.GetDouble(4):F2,-10} {reader.GetInt64(5)}");
        }
    }

    // 9. Įvesti egzamino pažymį
    static void AddExamGrade(NpgsqlConnection conn)
    {
        Console.WriteLine("\n--- EGZAMINO PAŽYMIO ĮVEDIMAS ---");
        
        Console.Write("Studento numeris: ");
        if (!int.TryParse(Console.ReadLine(), out int studentoNr))
        {
            Console.WriteLine("Neteisingas numeris.");
            return;
        }
        
        // Parodome studento lankomas disciplinas
        Console.WriteLine("\nStudento lankomi dalykai:");
        string sqlDalykai = @"SELECT d.Pavadinimas FROM Lanko_dalyka ld
                             JOIN Dalykas d ON ld.Dalyko_pav = d.Pavadinimas
                             WHERE ld.Studento_nr = @nr";
        using (var cmd = new NpgsqlCommand(sqlDalykai, conn))
        {
            cmd.Parameters.AddWithValue("nr", studentoNr);
            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                Console.WriteLine($"  • {reader.GetString(0)}");
            }
        }
        
        Console.Write("\nDalyko pavadinimas: ");
        string dalykas = Console.ReadLine();
        
        // Parodome galimus egzaminus
        Console.WriteLine("\nPlanuojami egzaminai:");
        string sqlEgz = "SELECT Data FROM Egzaminas WHERE Dalykas = @dalykas";
        using (var cmd = new NpgsqlCommand(sqlEgz, conn))
        {
            cmd.Parameters.AddWithValue("dalykas", dalykas);
            using var reader = cmd.ExecuteReader();
            while (reader.Read())
            {
                Console.WriteLine($"  • {reader.GetDateTime(0):yyyy-MM-dd}");
            }
        }
        
        Console.Write("\nEgzamino data (yyyy-MM-dd): ");
        if (!DateTime.TryParse(Console.ReadLine(), out DateTime data))
        {
            Console.WriteLine("Neteisinga data.");
            return;
        }
        
        Console.Write("Pažymys (1-10): ");
        if (!decimal.TryParse(Console.ReadLine(), out decimal pazymys))
        {
            Console.WriteLine("Neteisingas pažymys.");
            return;
        }
        
        string sql = @"INSERT INTO Laiko (Studento_nr, Dalykas, Data, Pazymys)
                      VALUES (@nr, @dalykas, @data, @pazymys)";
        
        try
        {
            using var cmd = new NpgsqlCommand(sql, conn);
            cmd.Parameters.AddWithValue("nr", studentoNr);
            cmd.Parameters.AddWithValue("dalykas", dalykas);
            cmd.Parameters.AddWithValue("data", data);
            cmd.Parameters.AddWithValue("pazymys", pazymys);
            
            cmd.ExecuteNonQuery();
            Console.WriteLine("\n✓ Pažymys sėkmingai įvestas!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"\n✗ Klaida: {ex.Message}");
        }
    }

    // 10. Materialized view - programų statistika
    static void ShowProgramStatistics(NpgsqlConnection conn)
    {
        Console.WriteLine("\n--- STUDIJŲ PROGRAMŲ STATISTIKA ---");
        
        // Atnaujinti materialized view
        using (var cmd = new NpgsqlCommand("REFRESH MATERIALIZED VIEW Studiju_programu_statistika", conn))
        {
            cmd.ExecuteNonQuery();
        }
        
        string sql = "SELECT * FROM Studiju_programu_statistika ORDER BY Studentu_skaicius DESC";
        
        using var cmd2 = new NpgsqlCommand(sql, conn);
        using var reader = cmd2.ExecuteReader();
        
        Console.WriteLine($"{"Programa",-25} {"Studentų",-10} {"Vidurkis",-10} {"Neišlaikyta"}");
        Console.WriteLine(new string('-', 60));
        
        while (reader.Read())
        {
            string programa = reader.GetString(0);
            long studentai = reader.GetInt64(1);
            var vidurkis = reader.IsDBNull(2) ? "N/A" : reader.GetDecimal(2).ToString("F2");
            long neislaikyta = reader.GetInt64(3);
            
            Console.WriteLine($"{programa,-25} {studentai,-10} {vidurkis,-10} {neislaikyta}");
        }
    }

    // 11. Materialized view - dėstytojų darbo krūvis
    static void ShowTeacherWorkload(NpgsqlConnection conn)
    {
        Console.WriteLine("\n--- DĖSTYTOJŲ DARBO KRŪVIS ---");
        
        // Atnaujinti materialized view
        using (var cmd = new NpgsqlCommand("REFRESH MATERIALIZED VIEW Destytoju_darbo_kruvis", conn))
        {
            cmd.ExecuteNonQuery();
        }
        
        string sql = @"SELECT Destytojo_nr, Vardas, Pavarde, Destomu_dalyku_sk, Mokomu_studentu_sk
                       FROM Destytoju_darbo_kruvis
                       ORDER BY Mokomu_studentu_sk DESC";
        
        using var cmd2 = new NpgsqlCommand(sql, conn);
        using var reader = cmd2.ExecuteReader();
        
        Console.WriteLine($"{"Nr",-5} {"Vardas",-15} {"Pavardė",-15} {"Dalykų",-10} {"Studentų"}");
        Console.WriteLine(new string('-', 65));
        
        while (reader.Read())
        {
            Console.WriteLine($"{reader.GetInt32(0),-5} {reader.GetString(1),-15} {reader.GetString(2),-15} " +
                            $"{reader.GetInt64(3),-10} {reader.GetInt64(4)}");
        }
    }
}