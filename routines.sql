    -- Function to random marks between 70 and 100
CREATE OR REPLACE FUNCTION get_random_marks() 
        RETURNS INTEGER AS $$
        BEGIN
            RETURN 100*(0.7 + random()*0.3);
        END;
        $$ LANGUAGE plpgsql;
    
-- Function to update marks table
CREATE OR REPLACE FUNCTION marks_updater() 
        RETURNS VOID AS $$
        DECLARE 
            i INTEGER;
            a INTEGER;
            b INTEGER;
            c INTEGER;
            d INTEGER;
        BEGIN
            TRUNCATE marks CASCADE;
            for i in SELECT id FROM info
            LOOP
                    a := get_random_marks();
                    b := get_random_marks();
                    c := get_random_marks();
                    d := get_random_marks();
                    INSERT INTO marks (id, sub1, sub2, sub3, sub4, total)
                    VALUES (i, a, b, c, d, (a+b+c+d));
            END LOOP;
        END;
        $$ LANGUAGE plpgsql;

-- Function to find toppers
CREATE OR REPLACE FUNCTION topper_finder() 
        RETURNS VOID AS $$
        BEGIN
            TRUNCATE toppers CASCADE;
            INSERT INTO toppers (id, name, sub1, sub2, sub3, sub4, total)
            SELECT info.id, name, sub1, sub2, sub3, sub4, total
            FROM info JOIN marks ON info.id = marks.id
            ORDER BY total DESC LIMIT 3;
        END;
        $$ LANGUAGE plpgsql;