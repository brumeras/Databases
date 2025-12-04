using System;
using System.Data;
using Npgsql;

class Program
{
    static string connString = "Host=localhost;Port=5432;Database=universitetas;Username=semilija25;Password=";

    static void Main()
    {
        using var conn = new NpgsqlConnection(connString);
        conn.Open();
        Console.WriteLine("Prisijungta prie DB!");

        while (true)
        {
            Console.WriteLine("\n--- MENIU ---");
            Console.WriteLine("1. Rodyti studentus");
            Console.WriteLine("2. Įvesti naują studentą");
            Console.WriteLine("3. Atnaujinti studento grupę (TRANSAKCIJA)");
            Console.WriteLine("4. Ištrinti studentą");
            Console.WriteLine("5. Rodyti studentų vidurkius (VIEW)");
            Console.WriteLine("0. Baigti");
            Console.Write("Pasirinkite: ");
            var choice = Console.ReadLine();

            switch (choice)
            {
                case "1": ShowStudents(conn); break;
                case "2": InsertStudent(conn); break;
                case "3": UpdateGroupTransaction(conn); break;
                case "4": DeleteStudent(conn); break;
                case "5": ShowAverages(conn); break;
                case "0": return;
            }
        }
    }

    static void ShowStudents(NpgsqlConnection conn)
    {
        using var cmd = new NpgsqlCommand("SELECT Studento_nr, Vardas, Pavarde, Studiju_programa_pav FROM Studentas", conn);
        using var reader = cmd.ExecuteReader();
        Console.WriteLine("Studentai:");
        while (reader.Read())
        {
            Console.WriteLine($"{reader.GetInt32(0)}: {reader.GetString(1)} {reader.GetString(2)} ({reader.GetString(3)})");
        }
    }

    static void InsertStudent(NpgsqlConnection conn)
    {
        Console.Write("Studento nr: ");
        int id = int.Parse(Console.ReadLine());
        Console.Write("Vardas: ");
        string vardas = Console.ReadLine();
        Console.Write("Pavardė: ");
        string pavarde = Console.ReadLine();
        Console.Write("Programa: ");
        string prog = Console.ReadLine();
        Console.Write("Balas: ");
        decimal balas = decimal.Parse(Console.ReadLine());

        string sql = "INSERT INTO Studentas (Studento_nr, Vardas, Pavarde, Studiju_programa_pav, Stojamasis_balas) VALUES (@id,@v,@p,@prog,@balas)";
        using var cmd = new NpgsqlCommand(sql, conn);
        cmd.Parameters.AddWithValue("id", id);
        cmd.Parameters.AddWithValue("v", vardas);
        cmd.Parameters.AddWithValue("p", pavarde);
        cmd.Parameters.AddWithValue("prog", prog);
        cmd.Parameters.AddWithValue("balas", balas);
        cmd.ExecuteNonQuery();
        Console.WriteLine("Studentas įvestas.");
    }

    static void UpdateGroupTransaction(NpgsqlConnection conn)
    {
        Console.Write("Studento nr: ");
        int id = int.Parse(Console.ReadLine());
        Console.Write("Naujas grupės ID: ");
        int gid = int.Parse(Console.ReadLine());

        using var tx = conn.BeginTransaction();
        try
        {
            using var cmd = new NpgsqlCommand("UPDATE Studentas SET Grupes_numeris=@gid WHERE Studento_nr=@id", conn, tx);
            cmd.Parameters.AddWithValue("gid", gid);
            cmd.Parameters.AddWithValue("id", id);
            cmd.ExecuteNonQuery();
            tx.Commit();
            Console.WriteLine("Grupė atnaujinta.");
        }
        catch (Exception ex)
        {
            tx.Rollback();
            Console.WriteLine("Klaida: " + ex.Message);
        }
    }

    static void DeleteStudent(NpgsqlConnection conn)
    {
        Console.Write("Studento nr: ");
        int id = int.Parse(Console.ReadLine());

        using var tx = conn.BeginTransaction();
        try
        {
            using var cmd1 = new NpgsqlCommand("DELETE FROM Lanko_dalyka WHERE Studento_nr=@id", conn, tx);
            cmd1.Parameters.AddWithValue("id", id);
            cmd1.ExecuteNonQuery();

            using var cmd2 = new NpgsqlCommand("DELETE FROM Laiko WHERE Studento_nr=@id", conn, tx);
            cmd2.Parameters.AddWithValue("id", id);
            cmd2.ExecuteNonQuery();

            using var cmd3 = new NpgsqlCommand("DELETE FROM Studentas WHERE Studento_nr=@id", conn, tx);
            cmd3.Parameters.AddWithValue("id", id);
            int del = cmd3.ExecuteNonQuery();

            tx.Commit();
            Console.WriteLine(del > 0 ? "Studentas ištrintas." : "Studentas nerastas.");
        }
        catch (Exception ex)
        {
            tx.Rollback();
            Console.WriteLine("Nepavyko: " + ex.Message);
        }
    }

    static void ShowAverages(NpgsqlConnection conn)
    {
        using var cmd = new NpgsqlCommand("SELECT Studento_nr, Vardas, Pavarde, Studiju_programa, Vidurkis FROM Studentu_egz_vidurkiai", conn);
        using var reader = cmd.ExecuteReader();
        Console.WriteLine("Vidurkiai:");
        while (reader.Read())
        {
            Console.WriteLine($"{reader.GetInt32(0)}: {reader.GetString(1)} {reader.GetString(2)}, programa={reader.GetString(3)}, vidurkis={reader.GetDouble(4):F2}");
        }
    }
}