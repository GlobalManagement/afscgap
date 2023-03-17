SELECT
    min(subset.min_cpue) AS min_cpue,
    max(subset.max_cpue) AS max_cpue,
    min(subset.temperature_delta) AS min_temperature,
    max(subset.temperature_delta) AS max_temperature,
    sum(subset.first_weight) / sum(subset.first_area_swept) AS first_cpue,
    sum(subset.second_weight) / sum(subset.second_area_swept) AS second_cpue
FROM
    (
        SELECT
            LEAST(sum(first.cpue), sum(second.cpue)) AS min_cpue,
            GREATEST(sum(first.cpue), sum(second.cpue)) AS max_cpue,
            sum(second.temperature) - sum(first.temperature) AS temperature_delta,
            sum(first.weight) AS first_weight,
            sum(first.area_swept) AS first_area_swept,
            sum(second.weight) AS second_weight,
            sum(second.area_swept) AS second_area_swept
        FROM
            (
                SELECT
                    sum(weight) / sum(area_swept) AS cpue,
                    sum(weight) AS weight,
                    sum(area_swept) AS area_swept,
                    sum(temperature * num_records_aggregated) / sum(num_records_aggregated) AS temperature,
                    geohash AS geohash
                FROM
                    (
                        SELECT
                            %s AS temperature,
                            substr(geohash, 0, %d) AS geohash,
                            weight AS weight,
                            area_swept AS area_swept,
                            num_records_aggregated AS num_records_aggregated
                        FROM
                            records
                        WHERE
                            year = ?
                            AND survey = ?
                            AND %s = ?
                    ) firstInner
                GROUP BY
                    geohash
            ) first
        INNER JOIN
            (
                SELECT
                    sum(weight) / sum(area_swept) AS cpue,
                    sum(weight) AS weight,
                    sum(area_swept) AS area_swept,
                    sum(temperature * num_records_aggregated) / sum(num_records_aggregated) AS temperature,
                    geohash AS geohash
                FROM
                    (
                        SELECT
                            %s AS temperature,
                            substr(geohash, 0, %d) AS geohash,
                            weight AS weight,
                            area_swept AS area_swept,
                            num_records_aggregated AS num_records_aggregated
                        FROM
                            records
                        WHERE
                            year = ?
                            AND survey = ?
                            AND %s = ?
                    ) firstInner
                GROUP BY
                    geohash
            ) second
        ON
            first.geohash = second.geohash
    ) subset
