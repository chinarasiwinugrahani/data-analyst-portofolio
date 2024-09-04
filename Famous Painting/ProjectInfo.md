# Project: Famous Painting Dataset Analysis

This data analysis project utilizes the [Famous Painting](https://www.kaggle.com/datasets/mexwell/famous-paintings) dataset sourced from Kaggle. The analysis is done using MySQL, focusing on solving several problem statements obtained from the YouTube video [SQL Case Study techTFQ](https://www.youtube.com/watch?v=AZ29DXaJ1Ts).

## About Data
The data used in this project consists of several tables.
| Table           | Column |
| :-------------- | :--    |
| artist          | artist_id, full_name, first_name, middle_name, last_name, nationality, style, birth, date  |
| canvas_size     | size_id, width, height, laabel                                                             |
| image_link      | work_id, url, thumbnail_small_url, thumbnail_large_url                                     |
| museum          | museum_id, name, address, city, state, postal, country, phone, url                         |
| museum_hours    | museum_id, day, open, close                                                                |
| product_size    | work_id, size_id, sale_price, regular_price                                                |
| subject         | work_id, subject                                                                           |
| work            | work_id, name, artist_id, style, museum_id                                                 |

## Problem Statements
1.	Fetch all the paintings which are not displayed on any museums.
2.	Are there museums without any paintings?
3.	How many paintings have an asking price of more than their regular price?
4.	Identify the paintings whose asking price is less than 50% of its regular price.
5.	Which canva size costs the most?
6.	Delete duplicate records from work, product_size, subject and image_link tables.
7.	Identify the museums with invalid city information in the given dataset.
8.	Museum hours table has 1 invalid entry. Identify it and remove it.
9.	Fetch the top 10 most famous painting subject
10. Identify the museums which are open on both Sunday and Monday. Display museum name and city.
11. How many museums are open every single day?
12. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum).
13. Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist).
14. Display the 3 least popular canva sizes.
15. Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
16. Which museum has the most no of most popular painting style?
17. Identify the artists whose paintings are displayed in multiple countries.

---

If you have any feedback or questions, please feel free to reach out. Thank you!
