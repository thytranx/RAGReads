// 1. First, delete all relationships and nodes in the database
MATCH ()-[r]-()
DELETE r;

MATCH (n)
DELETE n;

// 2. CONSTRAINTS
CREATE CONSTRAINT book_isbn IF NOT EXISTS FOR (b:BOOK) REQUIRE b.ISBN IS UNIQUE;
CREATE CONSTRAINT user_id IF NOT EXISTS FOR (u:USER) REQUIRE u.UserID IS UNIQUE;
CREATE CONSTRAINT city_name IF NOT EXISTS FOR (c:CITY) REQUIRE c.Name IS UNIQUE;
CREATE CONSTRAINT state_name IF NOT EXISTS FOR (s:STATE) REQUIRE s.Name IS UNIQUE;
CREATE CONSTRAINT country_name IF NOT EXISTS FOR (c:COUNTRY) REQUIRE c.Name IS UNIQUE;
CREATE CONSTRAINT publisher_name IF NOT EXISTS FOR (p:PUBLISHER) REQUIRE p.Name IS UNIQUE;
CREATE CONSTRAINT genre_name IF NOT EXISTS FOR (g:GENRE) REQUIRE g.Name IS UNIQUE;
CREATE CONSTRAINT author_name IF NOT EXISTS FOR (a:AUTHOR) REQUIRE a.Name IS UNIQUE;

// 3. BASE DATA CREATION
// 3.1 Create Locations
UNWIND [
    ["Dallas", "Texas", "US"],
    ["San Francisco", "California", "US"],
    ["Los Angeles", "California", "US"],
    ["London", "England", "UK"],
    ["Chicago", "Illinois", "US"],
    ["Boston", "Massachusetts", "US"],
    ["Seattle", "Washington", "US"],
    ["Austin", "Texas", "US"],
    ["Miami", "Florida", "US"],
    ["New York", "New York", "US"],
    ["Portland", "Oregon", "US"],
    ["Atlanta", "Georgia", "US"],
    ["New Orleans", "Louisiana", "US"],
    ["Minneapolis", "Minnesota", "US"],
    ["Denver", "Colorado", "US"],
    ["Washington DC", "District of Columbia", "US"]
] AS city
MERGE (c:CITY {Name: city[0]})
MERGE (s:STATE {Name: city[1]})
MERGE (cnt:COUNTRY {Name: city[2]})
MERGE (c)-[:PART_OF]->(s)
MERGE (s)-[:PART_OF]->(cnt);

// 3.2 Create Genres
UNWIND [
    "Business & Finance", 
    "Self-Help", 
    "Literary Fiction", 
    "Romance", 
    "Technology", 
    "Science Fiction",
    "Mystery",
    "Thriller",
    "Fantasy",
    "Biography",
    "History",
    "Contemporary Fiction",
    "Satire"
] AS genreName
MERGE (g:GENRE {Name: genreName});

// 3.3 Create Publishers
UNWIND [
    "Penguin Random House", 
    "HarperCollins", 
    "Simon & Schuster", 
    "Random House",
    "Penguin Books",
    "Macmillan Publishers",
    "Hachette Book Group",
    "Scholastic"
] AS pubName
MERGE (p:PUBLISHER {Name: pubName});

// 4. AUTHORS
CREATE 
(jane_austen:PERSON:AUTHOR {
    AuthorID: "AUTH001",
    Name: "Jane Austen",
    BirthDate: "1775-12-16",
    DeathDate: "1817-07-18",
    Nationality: "British",
    Biography: "English novelist known for six major novels, including Pride and Prejudice"
}),
(emily_bronte:PERSON:AUTHOR {
    AuthorID: "AUTH002",
    Name: "Emily Brontë",
    BirthDate: "1818-07-30",
    DeathDate: "1848-12-19",
    Nationality: "British",
    Biography: "One of the Brontë sisters, known for her only novel Wuthering Heights"
}),
(charlotte_bronte:PERSON:AUTHOR {
    AuthorID: "AUTH003",
    Name: "Charlotte Brontë",
    BirthDate: "1816-04-21",
    DeathDate: "1855-03-31",
    Nationality: "British",
    Biography: "English novelist and poet, the eldest of the Brontë sisters who survived into adulthood"
}),
(sally_rooney:PERSON:AUTHOR {
    AuthorID: "AUTH004",
    Name: "Sally Rooney",
    BirthDate: "1991-02-20",
    Nationality: "Irish",
    Biography: "Contemporary Irish novelist known for Conversations with Friends and Normal People"
}),
(celeste_ng:PERSON:AUTHOR {
    AuthorID: "AUTH005",
    Name: "Celeste Ng",
    BirthDate: "1980-07-30",
    Nationality: "American",
    Biography: "American writer and novelist known for Everything I Never Told You and Little Fires Everywhere"
}),
(delia_owens:PERSON:AUTHOR {
    AuthorID: "AUTH006",
    Name: "Delia Owens",
    BirthDate: "1949-04-04",
    Nationality: "American",
    Biography: "American author and zoologist known for her debut novel Where the Crawdads Sing"
}),
(gillian_flynn:PERSON:AUTHOR {
    AuthorID: "AUTH007",
    Name: "Gillian Flynn",
    BirthDate: "1971-02-24",
    Nationality: "American",
    Biography: "American writer known for sharp-witted, suspenseful thrillers including Gone Girl and Sharp Objects"
}),
(stieg_larsson:PERSON:AUTHOR {
    AuthorID: "AUTH008",
    Name: "Stieg Larsson",
    BirthDate: "1954-08-15",
    DeathDate: "2004-11-09",
    Nationality: "Swedish",
    Biography: "Swedish journalist and writer known for the Millennium series, beginning with The Girl with the Dragon Tattoo"
}),
(jk_rowling:PERSON:AUTHOR {
    AuthorID: "AUTH009",
    Name: "J.K. Rowling",
    BirthDate: "1965-07-31",
    Nationality: "British",
    Biography: "British author best known for the Harry Potter fantasy series"
}),
(george_martin:PERSON:AUTHOR {
    AuthorID: "AUTH010",
    Name: "George R.R. Martin",
    BirthDate: "1948-09-20",
    Nationality: "American",
    Biography: "American novelist and short story writer, best known for A Song of Ice and Fire series"
}),
(frank_herbert:PERSON:AUTHOR {
    AuthorID: "AUTH011",
    Name: "Frank Herbert",
    BirthDate: "1920-10-08",
    DeathDate: "1986-02-11",
    Nationality: "American",
    Biography: "American science fiction writer best known for the Dune saga"
}),
(liu_cixin:PERSON:AUTHOR {
    AuthorID: "AUTH012",
    Name: "Liu Cixin",
    BirthDate: "1963-06-23",
    Nationality: "Chinese",
    Biography: "Chinese science fiction writer, most famous for The Three-Body Problem trilogy"
}),
(yuval_harari:PERSON:AUTHOR {
    AuthorID: "AUTH013",
    Name: "Yuval Noah Harari",
    BirthDate: "1976-02-24",
    Nationality: "Israeli",
    Biography: "Israeli historian and professor, known for Sapiens and Homo Deus"
}),
(michelle_obama:PERSON:AUTHOR {
    AuthorID: "AUTH014",
    Name: "Michelle Obama",
    BirthDate: "1964-01-17",
    Nationality: "American",
    Biography: "American attorney, author, and former First Lady of the United States"
});

// 5. BOOKS
// 5.1 First batch of books
UNWIND [
    {ISBN: "978-0141439518", BookTitle: "Pride and Prejudice", Year: 1813, Publisher: "Penguin Books", Genres: ["Romance", "Literary Fiction", "Satire"], Author: "Jane Austen"},
    {ISBN: "978-0743273565", BookTitle: "The Great Gatsby", Year: 1925, Publisher: "Simon & Schuster", Genres: ["Literary Fiction"], Author: "F. Scott Fitzgerald"},
    {ISBN: "978-1982137458", BookTitle: "Think and Grow Rich", Year: 1937, Publisher: "Simon & Schuster", Genres: ["Business & Finance", "Self-Help"], Author: "Napoleon Hill"},
    {ISBN: "978-0385349570", BookTitle: "Zero to One", Year: 2014, Publisher: "Penguin Random House", Genres: ["Business & Finance", "Technology"], Author: "Peter Thiel"},
    {ISBN: "978-0062457714", BookTitle: "The Subtle Art of Not Giving a F*ck", Year: 2016, Publisher: "HarperCollins", Genres: ["Self-Help"], Author: "Mark Manson"},
    {ISBN: "978-0307887894", BookTitle: "Ready Player One", Year: 2011, Publisher: "Random House", Genres: ["Science Fiction", "Technology"], Author: "Ernest Cline"}
] AS book
MERGE (b:BOOK {ISBN: book.ISBN})
SET b.BookTitle = book.BookTitle,
    b.PublishedYear = book.Year
WITH b, book
MATCH (p:PUBLISHER {Name: book.Publisher})
MERGE (p)-[:PUBLISHES]->(b)
WITH b, book
UNWIND book.Genres AS genre
MATCH (g:GENRE {Name: genre})
MERGE (b)-[:BELONGS_TO]->(g);

// 5.2 Create more books
CREATE 
// Classic literature
(sense_book:BOOK {
    ISBN: "0141439661",
    BookTitle: "Sense and Sensibility",
    PublishedDate: "1811-10-30",
    BookType: ["Paperback", "eBook", "Audio"],
    Description: "Jane Austen's first published novel about two sisters with contrasting temperaments",
    Language: "English",
    PageCount: 409
}),
(emma_book:BOOK {
    ISBN: "0141439580",
    BookTitle: "Emma",
    PublishedDate: "1815-12-23",
    BookType: ["Paperback", "eBook", "Audio"],
    Description: "A comedy of manners about matchmaking and romantic misunderstandings",
    Language: "English",
    PageCount: 474
}),
(persuasion_book:BOOK {
    ISBN: "0141439688",
    BookTitle: "Persuasion",
    PublishedDate: "1817-12-20",
    BookType: ["Paperback", "eBook"],
    Description: "Jane Austen's last completed novel about second chances at love",
    Language: "English",
    PageCount: 249
}),
(wuthering_book:BOOK {
    ISBN: "0141439556",
    BookTitle: "Wuthering Heights",
    PublishedDate: "1847-12-15",
    BookType: ["Paperback", "eBook", "Audio"],
    Description: "Emily Brontë's passionate and tempestuous novel set on the Yorkshire moors",
    Language: "English",
    PageCount: 416
}),
(jane_eyre_book:BOOK {
    ISBN: "0142437204",
    BookTitle: "Jane Eyre",
    PublishedDate: "1847-10-16",
    BookType: ["Paperback", "eBook", "Audio"],
    Description: "Charlotte Brontë's novel about a plain governess who finds love with the brooding Mr. Rochester",
    Language: "English",
    PageCount: 532
}),

// Contemporary fiction
(normal_people:BOOK {
    ISBN: "1984822179",
    BookTitle: "Normal People",
    PublishedDate: "2018-08-28",
    BookType: ["Paperback", "eBook", "Audio"],
    Description: "A modern love story about two young people navigating adulthood and their complicated relationship",
    Language: "English",
    PageCount: 288
}),
(little_fires:BOOK {
    ISBN: "0735224293",
    BookTitle: "Little Fires Everywhere",
    PublishedDate: "2017-09-12",
    BookType: ["Hardcover", "eBook", "Audio"],
    Description: "A novel about the intertwined fates of a picture-perfect family and the enigmatic mother and daughter who upend their lives",
    Language: "English",
    PageCount: 352
}),
(where_crawdads:BOOK {
    ISBN: "0735219095",
    BookTitle: "Where the Crawdads Sing",
    PublishedDate: "2018-08-14",
    BookType: ["Hardcover", "Paperback", "eBook", "Audio"],
    Description: "A coming-of-age murder mystery about an isolated girl growing up in the marshes of North Carolina",
    Language: "English",
    PageCount: 384
}),

// Mystery/thriller
(gone_girl:BOOK {
    ISBN: "0307588378",
    BookTitle: "Gone Girl",
    PublishedDate: "2012-06-05",
    BookType: ["Paperback", "eBook", "Audio"],
    Description: "A psychological thriller about a woman who disappears on her fifth wedding anniversary",
    Language: "English",
    PageCount: 415
}),
(girl_dragon:BOOK {
    ISBN: "0307949486",
    BookTitle: "The Girl with the Dragon Tattoo",
    PublishedDate: "2008-09-16",
    BookType: ["Paperback", "eBook", "Audio"],
    Description: "A gripping mystery featuring journalist Mikael Blomkvist and hacker Lisbeth Salander",
    Language: "English",
    PageCount: 672
}),

// Fantasy
(harry_potter1:BOOK {
    ISBN: "0590353427",
    BookTitle: "Harry Potter and the Sorcerer's Stone",
    PublishedDate: "1997-06-26",
    BookType: ["Hardcover", "Paperback", "eBook", "Audio"],
    Description: "The first book in J.K. Rowling's series about a young wizard discovering his heritage",
    Language: "English",
    PageCount: 320
}),
(game_thrones:BOOK {
    ISBN: "0553593714",
    BookTitle: "A Game of Thrones",
    PublishedDate: "1996-08-01",
    BookType: ["Hardcover", "Paperback", "eBook", "Audio"],
    Description: "The first book in George R.R. Martin's epic fantasy series A Song of Ice and Fire",
    Language: "English",
    PageCount: 835
}),

// Science Fiction
(dune_book:BOOK {
    ISBN: "0441172717",
    BookTitle: "Dune",
    PublishedDate: "1965-08-01",
    BookType: ["Paperback", "eBook", "Audio"],
    Description: "Frank Herbert's epic science fiction masterpiece set in a distant future amidst a feudal interstellar society",
    Language: "English",
    PageCount: 696
}),
(three_body:BOOK {
    ISBN: "0765382032",
    BookTitle: "The Three-Body Problem",
    PublishedDate: "2014-11-11",
    BookType: ["Hardcover", "Paperback", "eBook", "Audio"],
    Description: "A Chinese science fiction novel about humanity's first contact with an alien civilization",
    Language: "English",
    PageCount: 400
}),

// Non-fiction
(sapiens_book:BOOK {
    ISBN: "0062316095",
    BookTitle: "Sapiens: A Brief History of Humankind",
    PublishedDate: "2014-02-10",
    BookType: ["Hardcover", "Paperback", "eBook", "Audio"],
    Description: "A sweeping overview of human history from the evolution of Homo sapiens to the present",
    Language: "English",
    PageCount: 464
}),
(becoming_book:BOOK {
    ISBN: "1524763136",
    BookTitle: "Becoming",
    PublishedDate: "2018-11-13",
    BookType: ["Hardcover", "Paperback", "eBook", "Audio"],
    Description: "Michelle Obama's memoir about her life journey from childhood to the White House",
    Language: "English",
    PageCount: 448
});

// 6. CONNECT AUTHORS TO BOOKS
MATCH (jane:PERSON:AUTHOR {Name: "Jane Austen"})
MATCH (sense:BOOK {BookTitle: "Sense and Sensibility"})
MATCH (emma:BOOK {BookTitle: "Emma"})
MATCH (persuasion:BOOK {BookTitle: "Persuasion"})
MATCH (pride:BOOK {BookTitle: "Pride and Prejudice"})
CREATE (jane)-[:WROTE]->(sense),
       (jane)-[:WROTE]->(emma),
       (jane)-[:WROTE]->(persuasion),
       (jane)-[:WROTE]->(pride);

MATCH (emily:PERSON:AUTHOR {Name: "Emily Brontë"})
MATCH (wuthering:BOOK {BookTitle: "Wuthering Heights"})
CREATE (emily)-[:WROTE]->(wuthering);

MATCH (charlotte:PERSON:AUTHOR {Name: "Charlotte Brontë"})
MATCH (jane_eyre:BOOK {BookTitle: "Jane Eyre"})
CREATE (charlotte)-[:WROTE]->(jane_eyre);

MATCH (sally:PERSON:AUTHOR {Name: "Sally Rooney"})
MATCH (normal:BOOK {BookTitle: "Normal People"})
CREATE (sally)-[:WROTE]->(normal);

MATCH (celeste:PERSON:AUTHOR {Name: "Celeste Ng"})
MATCH (fires:BOOK {BookTitle: "Little Fires Everywhere"})
CREATE (celeste)-[:WROTE]->(fires);

MATCH (delia:PERSON:AUTHOR {Name: "Delia Owens"})
MATCH (crawdads:BOOK {BookTitle: "Where the Crawdads Sing"})
CREATE (delia)-[:WROTE]->(crawdads);

MATCH (gillian:PERSON:AUTHOR {Name: "Gillian Flynn"})
MATCH (gone:BOOK {BookTitle: "Gone Girl"})
CREATE (gillian)-[:WROTE]->(gone);

MATCH (stieg:PERSON:AUTHOR {Name: "Stieg Larsson"})
MATCH (dragon:BOOK {BookTitle: "The Girl with the Dragon Tattoo"})
CREATE (stieg)-[:WROTE]->(dragon);

MATCH (jk:PERSON:AUTHOR {Name: "J.K. Rowling"})
MATCH (harry:BOOK {BookTitle: "Harry Potter and the Sorcerer's Stone"})
CREATE (jk)-[:WROTE]->(harry);

MATCH (george:PERSON:AUTHOR {Name: "George R.R. Martin"})
MATCH (thrones:BOOK {BookTitle: "A Game of Thrones"})
CREATE (george)-[:WROTE]->(thrones);

MATCH (frank:PERSON:AUTHOR {Name: "Frank Herbert"})
MATCH (dune:BOOK {BookTitle: "Dune"})
CREATE (frank)-[:WROTE]->(dune);

MATCH (liu:PERSON:AUTHOR {Name: "Liu Cixin"})
MATCH (three:BOOK {BookTitle: "The Three-Body Problem"})
CREATE (liu)-[:WROTE]->(three);

MATCH (yuval:PERSON:AUTHOR {Name: "Yuval Noah Harari"})
MATCH (sapiens:BOOK {BookTitle: "Sapiens: A Brief History of Humankind"})
CREATE (yuval)-[:WROTE]->(sapiens);

MATCH (michelle:PERSON:AUTHOR {Name: "Michelle Obama"})
MATCH (becoming:BOOK {BookTitle: "Becoming"})
CREATE (michelle)-[:WROTE]->(becoming);

// 7. LINK BOOKS TO GENRES
// Romance
MATCH (romance:GENRE {Name: "Romance"})
MATCH (sense:BOOK {BookTitle: "Sense and Sensibility"})
MATCH (emma:BOOK {BookTitle: "Emma"})
MATCH (persuasion:BOOK {BookTitle: "Persuasion"})
MATCH (normal:BOOK {BookTitle: "Normal People"})
MATCH (jane_eyre:BOOK {BookTitle: "Jane Eyre"})
MATCH (wuthering:BOOK {BookTitle: "Wuthering Heights"})
CREATE 
(sense)-[:BELONGS_TO]->(romance),
(emma)-[:BELONGS_TO]->(romance),
(persuasion)-[:BELONGS_TO]->(romance),
(normal)-[:BELONGS_TO]->(romance),
(jane_eyre)-[:BELONGS_TO]->(romance),
(wuthering)-[:BELONGS_TO]->(romance);

// Satire
MATCH (satire:GENRE {Name: "Satire"})
MATCH (sense:BOOK {BookTitle: "Sense and Sensibility"})
MATCH (emma:BOOK {BookTitle: "Emma"})
CREATE 
(sense)-[:BELONGS_TO]->(satire),
(emma)-[:BELONGS_TO]->(satire);

// Link contemporary fiction, mystery, thriller, etc. to books (similar pattern)
// Contemporary Fiction
MATCH (contemporary:GENRE {Name: "Contemporary Fiction"})
MATCH (normal:BOOK {BookTitle: "Normal People"})
MATCH (fires:BOOK {BookTitle: "Little Fires Everywhere"})
MATCH (crawdads:BOOK {BookTitle: "Where the Crawdads Sing"})
MATCH (gone:BOOK {BookTitle: "Gone Girl"})
CREATE 
(normal)-[:BELONGS_TO]->(contemporary),
(fires)-[:BELONGS_TO]->(contemporary),
(crawdads)-[:BELONGS_TO]->(contemporary),
(gone)-[:BELONGS_TO]->(contemporary);

// Mystery
MATCH (mystery:GENRE {Name: "Mystery"})
MATCH (crawdads:BOOK {BookTitle: "Where the Crawdads Sing"})
MATCH (dragon:BOOK {BookTitle: "The Girl with the Dragon Tattoo"})
CREATE 
(crawdads)-[:BELONGS_TO]->(mystery),
(dragon)-[:BELONGS_TO]->(mystery);

// Thriller
MATCH (thriller:GENRE {Name: "Thriller"})
MATCH (gone:BOOK {BookTitle: "Gone Girl"})
MATCH (dragon:BOOK {BookTitle: "The Girl with the Dragon Tattoo"})
CREATE 
(gone)-[:BELONGS_TO]->(thriller),
(dragon)-[:BELONGS_TO]->(thriller);

// Fantasy
MATCH (fantasy:GENRE {Name: "Fantasy"})
MATCH (harry:BOOK {BookTitle: "Harry Potter and the Sorcerer's Stone"})
MATCH (thrones:BOOK {BookTitle: "A Game of Thrones"})
CREATE 
(harry)-[:BELONGS_TO]->(fantasy),
(thrones)-[:BELONGS_TO]->(fantasy);

// Science Fiction
MATCH (scifi:GENRE {Name: "Science Fiction"})
MATCH (dune:BOOK {BookTitle: "Dune"})
MATCH (three:BOOK {BookTitle: "The Three-Body Problem"})
CREATE 
(dune)-[:BELONGS_TO]->(scifi),
(three)-[:BELONGS_TO]->(scifi);

// History
MATCH (history:GENRE {Name: "History"})
MATCH (sapiens:BOOK {BookTitle: "Sapiens: A Brief History of Humankind"})
CREATE (sapiens)-[:BELONGS_TO]->(history);

// Biography
MATCH (biography:GENRE {Name: "Biography"})
MATCH (becoming:BOOK {BookTitle: "Becoming"})
CREATE (becoming)-[:BELONGS_TO]->(biography);

// 8. CREATE MOVIES AND ADAPTATIONS
CREATE 
(pride_movie:MOVIE {
    MovieID: "MOV001",
    Title: "Pride and Prejudice",
    ReleaseYear: 2005,
    Director: "Joe Wright",
    Duration: 129
}),
(sense_movie:MOVIE {
    MovieID: "MOV002",
    Title: "Sense and Sensibility",
    ReleaseYear: 1995,
    Director: "Ang Lee",
    Duration: 136
}),
(emma_movie:MOVIE {
    MovieID: "MOV003",
    Title: "Emma",
    ReleaseYear: 2020,
    Director: "Autumn de Wilde",
    Duration: 124
}),
(wuthering_movie:MOVIE {
    MovieID: "MOV004",
    Title: "Wuthering Heights",
    ReleaseYear: 2011,
    Director: "Andrea Arnold",
    Duration: 129
}),
(jane_eyre_movie:MOVIE {
    MovieID: "MOV005",
    Title: "Jane Eyre",
    ReleaseYear: 2011,
    Director: "Cary Fukunaga",
    Duration: 120
}),
(normal_people_movie:MOVIE {
    MovieID: "MOV006",
    Title: "Normal People",
    ReleaseYear: 2020,
    Director: "Lenny Abrahamson, Hettie Macdonald",
    Duration: 339,
    Type: "TV Series"
}),
(little_fires_movie:MOVIE {
    MovieID: "MOV007",
    Title: "Little Fires Everywhere",
    ReleaseYear: 2020,
    Director: "Lynn Shelton",
    Duration: 480,
    Type: "TV Series"
}),
(where_crawdads_movie:MOVIE {
    MovieID: "MOV008",
    Title: "Where the Crawdads Sing",
    ReleaseYear: 2022,
    Director: "Olivia Newman",
    Duration: 125
}),
(gone_girl_movie:MOVIE {
    MovieID: "MOV009",
    Title: "Gone Girl",
    ReleaseYear: 2014,
    Director: "David Fincher",
    Duration: 149
}),
(girl_dragon_movie:MOVIE {
    MovieID: "MOV010",
    Title: "The Girl with the Dragon Tattoo",
    ReleaseYear: 2011,
    Director: "David Fincher",
    Duration: 158
}),
(harry_potter_movie:MOVIE {
    MovieID: "MOV011",
    Title: "Harry Potter and the Sorcerer's Stone",
    ReleaseYear: 2001,
    Director: "Chris Columbus",
    Duration: 152
}),
(game_thrones_movie:MOVIE {
    MovieID: "MOV012",
    Title: "Game of Thrones",
    ReleaseYear: 2011,
    Director: "Various",
    Duration: 4200,
    Type: "TV Series"
}),
(dune_movie:MOVIE {
    MovieID: "MOV013",
    Title: "Dune",
    ReleaseYear: 2021,
    Director: "Denis Villeneuve",
    Duration: 155
}),
(gatsby_movie:MOVIE {
    MovieID: "MOV014",
    Title: "The Great Gatsby",
    ReleaseYear: 2013,
    Director: "Baz Luhrmann",
    Duration: 143
}),
(ready_player_movie:MOVIE {
    MovieID: "MOV015",
    Title: "Ready Player One",
    ReleaseYear: 2018,
    Director: "Steven Spielberg",
    Duration: 140
});

// 9. LINK BOOKS TO MOVIES
MATCH (pride:BOOK {BookTitle: "Pride and Prejudice"})
MATCH (pride_movie:MOVIE {Title: "Pride and Prejudice"})
CREATE (pride)-[:ADAPTS_TO]->(pride_movie);

MATCH (sense_book:BOOK {BookTitle: "Sense and Sensibility"})
MATCH (sense_movie:MOVIE {Title: "Sense and Sensibility"})
CREATE (sense_book)-[:ADAPTS_TO]->(sense_movie);

MATCH (emma_book:BOOK {BookTitle: "Emma"})
MATCH (emma_movie:MOVIE {Title: "Emma"})
CREATE (emma_book)-[:ADAPTS_TO]->(emma_movie);

MATCH (wuthering_book:BOOK {BookTitle: "Wuthering Heights"})
MATCH (wuthering_movie:MOVIE {Title: "Wuthering Heights"})
CREATE (wuthering_book)-[:ADAPTS_TO]->(wuthering_movie);

MATCH (jane_eyre_book:BOOK {BookTitle: "Jane Eyre"})
MATCH (jane_eyre_movie:MOVIE {Title: "Jane Eyre"})
CREATE (jane_eyre_book)-[:ADAPTS_TO]->(jane_eyre_movie);

MATCH (normal_people:BOOK {BookTitle: "Normal People"})
MATCH (normal_people_movie:MOVIE {Title: "Normal People"})
CREATE (normal_people)-[:ADAPTS_TO]->(normal_people_movie);

MATCH (little_fires:BOOK {BookTitle: "Little Fires Everywhere"})
MATCH (little_fires_movie:MOVIE {Title: "Little Fires Everywhere"})
CREATE (little_fires)-[:ADAPTS_TO]->(little_fires_movie);

MATCH (where_crawdads:BOOK {BookTitle: "Where the Crawdads Sing"})
MATCH (where_crawdads_movie:MOVIE {Title: "Where the Crawdads Sing"})
CREATE (where_crawdads)-[:ADAPTS_TO]->(where_crawdads_movie);

MATCH (gone_girl:BOOK {BookTitle: "Gone Girl"})
MATCH (gone_girl_movie:MOVIE {Title: "Gone Girl"})
CREATE (gone_girl)-[:ADAPTS_TO]->(gone_girl_movie);

MATCH (girl_dragon:BOOK {BookTitle: "The Girl with the Dragon Tattoo"})
MATCH (girl_dragon_movie:MOVIE {Title: "The Girl with the Dragon Tattoo"})
CREATE (girl_dragon)-[:ADAPTS_TO]->(girl_dragon_movie);

MATCH (harry_potter1:BOOK {BookTitle: "Harry Potter and the Sorcerer's Stone"})
MATCH (harry_potter_movie:MOVIE {Title: "Harry Potter and the Sorcerer's Stone"})
CREATE (harry_potter1)-[:ADAPTS_TO]->(harry_potter_movie);

MATCH (game_thrones:BOOK {BookTitle: "A Game of Thrones"})
MATCH (game_thrones_movie:MOVIE {Title: "Game of Thrones"})
CREATE (game_thrones)-[:ADAPTS_TO]->(game_thrones_movie);

MATCH (dune_book:BOOK {BookTitle: "Dune"})
MATCH (dune_movie:MOVIE {Title: "Dune"})
CREATE (dune_book)-[:ADAPTS_TO]->(dune_movie);

MATCH (gatsby:BOOK {BookTitle: "The Great Gatsby"})
MATCH (gatsby_movie:MOVIE {Title: "The Great Gatsby"})
CREATE (gatsby)-[:ADAPTS_TO]->(gatsby_movie);

MATCH (ready_player:BOOK {BookTitle: "Ready Player One"})
MATCH (ready_player_movie:MOVIE {Title: "Ready Player One"})
CREATE (ready_player)-[:ADAPTS_TO]->(ready_player_movie);

// 10. CREATE USERS
CREATE 
(sarah:PERSON:USER {
    UserID: "5252680",
    Age: 32,
    Profession: "Marketing Manager",
    Networth: 120000,
    Gender: "Female",
    Ethnicity: "Caucasian",
    RelationshipStatus: "Married",
    Education: "Bachelor's Degree",
    Location: "New York"
}),
(michael:PERSON:USER {
    UserID: "5252681",
    Age: 45,
    Profession: "Doctor",
    Networth: 500000,
    Gender: "Male",
    Ethnicity: "African American",
    RelationshipStatus: "Divorced",
    Education: "MD",
    Location: "Chicago"
}),
(lisa:PERSON:USER {
    UserID: "5252682",
    Age: 19,
    Profession: "Student",
    Networth: 5000,
    Gender: "Female",
    Ethnicity: "Hispanic",
    RelationshipStatus: "Single",
    Education: "High School",
    Location: "Miami"
}),
(david:PERSON:USER {
    UserID: "5252683",
    Age: 57,
    Profession: "Professor",
    Networth: 300000,
    Gender: "Male",
    Ethnicity: "Caucasian",
    RelationshipStatus: "Married",
    Education: "PhD",
    Location: "Boston"
}),
(rachel:PERSON:USER {
    UserID: "5252684",
    Age: 29,
    Profession: "Software Engineer",
    Networth: 150000,
    Gender: "Female",
    Ethnicity: "Asian",
    RelationshipStatus: "In Relationship",
    Education: "Master's Degree",
    Location: "Seattle"
}),
(james:PERSON:USER {
    UserID: "5252685",
    Age: 38,
    Profession: "Architect",
    Networth: 200000,
    Gender: "Male",
    Ethnicity: "Caucasian",
    RelationshipStatus: "Married",
    Education: "Bachelor's Degree",
    Location: "Portland"
}),
(emily:PERSON:USER {
    UserID: "5252686",
    Age: 24,
    Profession: "Journalist",
    Networth: 70000,
    Gender: "Female",
    Ethnicity: "Caucasian",
    RelationshipStatus: "Single",
    Education: "Bachelor's Degree",
    Location: "San Francisco"
}),
(robert:PERSON:USER {
    UserID: "5252687",
    Age: 41,
    Profession: "Financial Analyst",
    Networth: 250000,
    Gender: "Male",
    Ethnicity: "African American",
    RelationshipStatus: "Married",
    Education: "MBA",
    Location: "Austin"
}),
(jennifer:PERSON:USER {
    UserID: "5252688",
    Age: 35,
    Profession: "Lawyer",
    Networth: 180000,
    Gender: "Female",
    Ethnicity: "Hispanic",
    RelationshipStatus: "Single",
    Education: "JD",
    Location: "Los Angeles"
}),
(daniel:PERSON:USER {
    UserID: "5252689",
    Age: 52,
    Profession: "Business Owner",
    Networth: 750000,
    Gender: "Male",
    Ethnicity: "Middle Eastern",
    RelationshipStatus: "Married",
    Education: "Bachelor's Degree",
    Location: "Dallas"
}),
(michelle:PERSON:USER {
    UserID: "5252690",
    Age: 27,
    Profession: "Nurse",
    Networth: 80000,
    Gender: "Female",
    Ethnicity: "African American",
    RelationshipStatus: "In Relationship",
    Education: "BSN",
    Location: "Atlanta"
}),
(anthony:PERSON:USER {
    UserID: "5252691",
    Age: 33,
    Profession: "Chef",
    Networth: 90000,
    Gender: "Male",
    Ethnicity: "Italian American",
    RelationshipStatus: "Single",
    Education: "Culinary School",
    Location: "New Orleans"
}),
(sophia:PERSON:USER {
    UserID: "5252692",
    Age: 22,
    Profession: "Graphic Designer",
    Networth: 45000,
    Gender: "Female",
    Ethnicity: "Asian",
    RelationshipStatus: "Single",
    Education: "Associate's Degree",
    Location: "Minneapolis"
}),
(william:PERSON:USER {
    UserID: "5252693",
    Age: 60,
    Profession: "Retired Teacher",
    Networth: 350000,
    Gender: "Male",
    Ethnicity: "Caucasian",
    RelationshipStatus: "Widowed",
    Education: "Master's Degree",
    Location: "Denver"
}),
(olivia:PERSON:USER {
    UserID: "5252694",
    Age: 31,
    Profession: "Psychologist",
    Networth: 120000,
    Gender: "Female",
    Ethnicity: "Biracial",
    RelationshipStatus: "Married",
    Education: "PsyD",
    Location: "Washington DC"
});

// 11. LINK USERS TO CITIES
MATCH (sarah:PERSON:USER {UserID: "5252680"}), (nyc:CITY {Name: "New York"})
CREATE (sarah)-[:LIVES_IN]->(nyc);

MATCH (michael:PERSON:USER {UserID: "5252681"}), (chicago:CITY {Name: "Chicago"})
CREATE (michael)-[:LIVES_IN]->(chicago);

MATCH (lisa:PERSON:USER {UserID: "5252682"}), (miami:CITY {Name: "Miami"})
CREATE (lisa)-[:LIVES_IN]->(miami);

MATCH (david:PERSON:USER {UserID: "5252683"}), (boston:CITY {Name: "Boston"})
CREATE (david)-[:LIVES_IN]->(boston);

MATCH (rachel:PERSON:USER {UserID: "5252684"}), (seattle:CITY {Name: "Seattle"})
CREATE (rachel)-[:LIVES_IN]->(seattle);

MATCH (james:PERSON:USER {UserID: "5252685"}), (portland:CITY {Name: "Portland"})
CREATE (james)-[:LIVES_IN]->(portland);

MATCH (emily:PERSON:USER {UserID: "5252686"}), (sf:CITY {Name: "San Francisco"})
CREATE (emily)-[:LIVES_IN]->(sf);

MATCH (robert:PERSON:USER {UserID: "5252687"}), (austin:CITY {Name: "Austin"})
CREATE (robert)-[:LIVES_IN]->(austin);

MATCH (jennifer:PERSON:USER {UserID: "5252688"}), (la:CITY {Name: "Los Angeles"})
CREATE (jennifer)-[:LIVES_IN]->(la);

MATCH (daniel:PERSON:USER {UserID: "5252689"}), (dallas:CITY {Name: "Dallas"})
CREATE (daniel)-[:LIVES_IN]->(dallas);

MATCH (michelle:PERSON:USER {UserID: "5252690"}), (atlanta:CITY {Name: "Atlanta"})
CREATE (michelle)-[:LIVES_IN]->(atlanta);

MATCH (anthony:PERSON:USER {UserID: "5252691"}), (nola:CITY {Name: "New Orleans"})
CREATE (anthony)-[:LIVES_IN]->(nola);

MATCH (sophia:PERSON:USER {UserID: "5252692"}), (minneapolis:CITY {Name: "Minneapolis"})
CREATE (sophia)-[:LIVES_IN]->(minneapolis);

MATCH (william:PERSON:USER {UserID: "5252693"}), (denver:CITY {Name: "Denver"})
CREATE (william)-[:LIVES_IN]->(denver);

MATCH (olivia:PERSON:USER {UserID: "5252694"}), (dc:CITY {Name: "Washington DC"})
CREATE (olivia)-[:LIVES_IN]->(dc);

// 12. CREATE READING RELATIONSHIPS
// Sarah - marketing manager who loves contemporary fiction
MATCH (sarah:PERSON:USER {UserID: "5252680"})
MATCH (normal:BOOK {BookTitle: "Normal People"})
CREATE (sarah)-[:READS {
    StartDate: "2024-01-05",
    EndDate: "2024-01-20",
    Status: "Completed",
    Progress: 100,
    Format: "eBook",
    Rating: 4.5
}]->(normal);

MATCH (sarah:PERSON:USER {UserID: "5252680"})
MATCH (fires:BOOK {BookTitle: "Little Fires Everywhere"})
CREATE (sarah)-[:READS {
    StartDate: "2024-02-01",
    EndDate: "2024-02-15",
    Status: "Completed",
    Progress: 100,
    Format: "eBook",
    Rating: 5
}]->(fires);

MATCH (sarah:PERSON:USER {UserID: "5252680"})
MATCH (crawdads:BOOK {BookTitle: "Where the Crawdads Sing"})
CREATE (sarah)-[:READS {
    StartDate: "2024-02-16",
    Status: "Reading",
    Progress: 35,
    Format: "eBook"
}]->(crawdads);

// Michael - doctor who enjoys science fiction and non-fiction
MATCH (michael:PERSON:USER {UserID: "5252681"})
MATCH (dune:BOOK {BookTitle: "Dune"})
CREATE (michael)-[:READS {
    StartDate: "2023-12-10",
    EndDate: "2024-01-15",
    Status: "Completed",
    Progress: 100,
    Format: "Audio",
    Rating: 5
}]->(dune);

MATCH (michael:PERSON:USER {UserID: "5252681"})
MATCH (three:BOOK {BookTitle: "The Three-Body Problem"})
CREATE (michael)-[:READS {
    StartDate: "2024-01-20",
    EndDate: "2024-02-10",
    Status: "Completed",
    Progress: 100,
    Format: "Audio",
    Rating: 4.5
}]->(three);

MATCH (michael:PERSON:USER {UserID: "5252681"})
MATCH (sapiens:BOOK {BookTitle: "Sapiens: A Brief History of Humankind"})
CREATE (michael)-[:READS {
    StartDate: "2024-02-15",
    Status: "Reading",
    Progress: 50,
    Format: "Audio"
}]->(sapiens);

// 13. CREATE AWARDS AND BOOK CLUBS

// First create awards
CREATE 
(pulitzer:AWARD {
    AwardID: "AWD002",
    Name: "Pulitzer Prize for Fiction",
    Year: "2019",
    Category: "Fiction",
    Prestige: "High"
}),
(booker:AWARD {
    AwardID: "AWD003",
    Name: "Booker Prize",
    Year: "2018",
    Category: "Fiction",
    Prestige: "High"
}),
(goodreads:AWARD {
    AwardID: "AWD004",
    Name: "Goodreads Choice Award",
    Year: "2018",
    Category: "Fiction",
    Prestige: "Medium"
}),
(hugo:AWARD {
    AwardID: "AWD005",
    Name: "Hugo Award",
    Year: "2015",
    Category: "Science Fiction",
    Prestige: "High"
}),
(national:AWARD {
    AwardID: "AWD006",
    Name: "National Book Award",
    Year: "2017",
    Category: "Fiction",
    Prestige: "High"
});

// Create book clubs
CREATE 
(reedsy:CLUB {
    ClubID: "CLUB9013",
    Name: "Reedsy Book Club",
    FocusGenre: "Mixed",
    MembershipCount: 22000,
    MeetingFrequency: "Weekly",
    Website: "https://reedsy.com/discovery/book-club"
}),
(goodreads_club:CLUB {
    ClubID: "CLUB9014",
    Name: "Goodreads Book Club",
    FocusGenre: "Contemporary Fiction",
    MembershipCount: 150000,
    MeetingFrequency: "Monthly",
    Website: "https://www.goodreads.com/group"
}),
(sf_club:CLUB {
    ClubID: "CLUB9015",
    Name: "Science Fiction & Fantasy Book Club",
    FocusGenre: "Science Fiction/Fantasy",
    MembershipCount: 35000,
    MeetingFrequency: "Biweekly",
    Website: "https://www.sffbookclub.org"
}),
(feminist_club:CLUB {
    ClubID: "CLUB9016",
    Name: "Feminist Book Club",
    FocusGenre: "Women's Literature",
    MembershipCount: 28000,
    MeetingFrequency: "Monthly",
    Website: "https://feministbookclub.com"
}),
(celebrity_club:CLUB {
    ClubID: "CLUB9017",
    Name: "Reese's Book Club",
    FocusGenre: "Women's Fiction",
    MembershipCount: 200000,
    MeetingFrequency: "Monthly",
    Website: "https://reesesbookclub.com"
});

// 14. CONNECT AWARDS TO BOOKS
MATCH (pride:BOOK {BookTitle: "Pride and Prejudice"})
MATCH (bbc:AWARD {AwardID: "AWD001"})
MERGE (pride)-[:WON {Date: "2003-12-12", Position: 4}]->(bbc);

MATCH (crawdads:BOOK {BookTitle: "Where the Crawdads Sing"})
MATCH (goodreads:AWARD {AwardID: "AWD004"})
CREATE (crawdads)-[:WON {Date: "2018-12-04", Position: 1}]->(goodreads);

MATCH (normal:BOOK {BookTitle: "Normal People"})
MATCH (booker:AWARD {AwardID: "AWD003"})
CREATE (normal)-[:WON {Date: "2018-11-15", Position: 5}]->(booker);

MATCH (fires:BOOK {BookTitle: "Little Fires Everywhere"})
MATCH (goodreads:AWARD {AwardID: "AWD004"})
CREATE (fires)-[:WON {Date: "2017-12-05", Position: 2}]->(goodreads);

MATCH (three:BOOK {BookTitle: "The Three-Body Problem"})
MATCH (hugo:AWARD {AwardID: "AWD005"})
CREATE (three)-[:WON {Date: "2015-08-22", Position: 1}]->(hugo);

// 15. CREATE CONFERENCES AND EVENTS
CREATE 
(bookexpo:EVENT {
    EventID: "CONF5679",
    Name: "BookExpo America",
    Theme: "Publishing Industry Conference",
    StartDate: "2024-05-29",
    EndDate: "2024-05-31",
    Website: "https://www.bookexpoamerica.com",
    City: "New York"
}),
(bay_festival:EVENT {
    EventID: "CONF5680",
    Name: "Bay Area Book Festival",
    Theme: "Literary Festival",
    StartDate: "2024-05-04",
    EndDate: "2024-05-05",
    Website: "https://www.baybookfest.org",
    City: "Berkeley"
}),
(los_festival:EVENT {
    EventID: "CONF5681",
    Name: "Los Angeles Times Festival of Books",
    Theme: "Book Fair",
    StartDate: "2024-04-22",
    EndDate: "2024-04-23",
    Website: "https://events.latimes.com/festivalofbooks",
    City: "Los Angeles"
}),
(edinburgh:EVENT {
    EventID: "CONF5682",
    Name: "Edinburgh International Book Festival",
    Theme: "International Literary Festival",
    StartDate: "2024-08-10",
    EndDate: "2024-08-26",
    Website: "https://www.edbookfest.co.uk",
    City: "Edinburgh"
}),
(book_con:EVENT {
    EventID: "CONF5683",
    Name: "BookCon",
    Theme: "Consumer Book Event",
    StartDate: "2024-05-30",
    EndDate: "2024-05-31",
    Website: "https://www.thebookcon.com",
    City: "New York"
});

// 16. CREATE SOCIAL MEDIA PLATFORMS
CREATE 
(twitter:SOCIALMEDIA {
    PlatformID: "SM001",
    Name: "Twitter",
    Type: "Microblogging"
}),
(instagram:SOCIALMEDIA {
    PlatformID: "SM002",
    Name: "Instagram",
    Type: "Photo Sharing"
}),
(facebook:SOCIALMEDIA {
    PlatformID: "SM003",
    Name: "Facebook",
    Type: "Social Network"
}),
(tiktok:SOCIALMEDIA {
    PlatformID: "SM004",
    Name: "TikTok",
    Type: "Video Sharing"
}),
(reddit:SOCIALMEDIA {
    PlatformID: "SM005",
    Name: "Reddit",
    Type: "Forum"
});

// 17. ADD METADATA ABOUT THE DATASET
CREATE (metadata:METADATA {
    DatasetName: "Book Recommendation Graph",
    CreationDate: "2025-02-26",
    BookCount: 20,
    UserCount: 15,
    AuthorCount: 14,
    MovieCount: 15,
    GenreCount: 13,
    Description: "Comprehensive book recommendation graph database with users, books, genres, authors, and social connections",
    Version: "2.0"
});