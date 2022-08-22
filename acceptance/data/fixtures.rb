# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Acceptance
  module Fixtures
    def stuffs_ddl_statement
      if emulator_enabled?
        <<~STUFFS
          CREATE TABLE stuffs (
              id INT64 NOT NULL,
              int INT64,
              float FLOAT64,
              bool BOOL,
              string STRING(MAX),
              byte BYTES(MAX),
              date DATE,
              timestamp TIMESTAMP OPTIONS (allow_commit_timestamp=true),
              ints ARRAY<INT64>,
              floats ARRAY<FLOAT64>,
              bools ARRAY<BOOL>,
              strings ARRAY<STRING(MAX)>,
              bytes ARRAY<BYTES(MAX)>,
              dates ARRAY<DATE>,
              timestamps ARRAY<TIMESTAMP>
          ) PRIMARY KEY (id)
        STUFFS
      else
        <<~STUFFS
          CREATE TABLE stuffs (
              id INT64 NOT NULL,
              int INT64,
              float FLOAT64,
              bool BOOL,
              string STRING(MAX),
              byte BYTES(MAX),
              date DATE,
              timestamp TIMESTAMP OPTIONS (allow_commit_timestamp=true),
              numeric NUMERIC,
              json JSON,
              ints ARRAY<INT64>,
              floats ARRAY<FLOAT64>,
              bools ARRAY<BOOL>,
              strings ARRAY<STRING(MAX)>,
              bytes ARRAY<BYTES(MAX)>,
              dates ARRAY<DATE>,
              timestamps ARRAY<TIMESTAMP>,
              numerics ARRAY<NUMERIC>,
              json_array ARRAY<JSON>
          ) PRIMARY KEY (id)
        STUFFS
      end
    end

    def stuff_pg_ddl_statement
      <<~STUFFS
        CREATE TABLE stuffs (
            id bigint NOT NULL,
            "int" bigint,
            "float" double precision,
            "numeric" NUMERIC,
            bool boolean,
            string character varying,
            byte bytea,
            date DATE,
            numerics numeric[],
            dates DATE[],
            PRIMARY KEY(id)
        );
      STUFFS
    end

    def stuffs_index_statement
      "CREATE INDEX IsStuffsIdPrime ON stuffs(bool, id)"
    end

    def commit_timestamp_test_ddl_statement
      <<~TEST
        CREATE TABLE commit_timestamp_test(committs TIMESTAMP OPTIONS (allow_commit_timestamp=true)) PRIMARY KEY (committs)
      TEST
    end

    def accounts_ddl_statement
      <<~ACCOUNTS
        CREATE TABLE accounts (
        account_id INT64 NOT NULL,
        username STRING(32),
        friends ARRAY<INT64>,
        active BOOL NOT NULL,
        reputation FLOAT64,
        avatar BYTES(8192)
        ) PRIMARY KEY (account_id)
      ACCOUNTS
    end

    def accounts_pg_ddl_statement
      <<~ACCOUNTS
        CREATE TABLE accounts (
            account_id INT NOT NULL,
            username TEXT,
            friends INT[],
            active BOOL NOT NULL,
            reputation FLOAT,
            avatar bytea,
            PRIMARY KEY(account_id)
        );
      ACCOUNTS
    end

    def lists_ddl_statement
      <<~LISTS
        CREATE TABLE task_lists (
        account_id INT64 NOT NULL,
        task_list_id INT64 NOT NULL,
        description STRING(1024) NOT NULL
        ) PRIMARY KEY (account_id, task_list_id),
        INTERLEAVE IN PARENT accounts ON DELETE CASCADE
      LISTS
    end

    def lists_pg_ddl_statement
      <<~LISTS
        CREATE TABLE task_lists (
            account_id INT NOT NULL,
            task_list_id INT NOT NULL,
            description TEXT NOT NULL,
            PRIMARY KEY (account_id, task_list_id)
        ) INTERLEAVE IN PARENT accounts ON DELETE CASCADE
      LISTS
    end

    def items_ddl_statement
      <<~ITEMS
        CREATE TABLE task_items (
        account_id INT64 NOT NULL,
        task_list_id INT64 NOT NULL,
        task_item_id INT64 NOT NULL,
        description STRING(1024) NOT NULL,
        active BOOL NOT NULL,
        priority INT64 NOT NULL,
        due_date DATE,
        created_at TIMESTAMP,
        updated_at TIMESTAMP
        ) PRIMARY KEY (account_id, task_list_id, task_item_id),
        INTERLEAVE IN PARENT task_lists ON DELETE CASCADE
      ITEMS
    end

    def schema_pg_ddl_statements
      [
        stuff_pg_ddl_statement,
        accounts_pg_ddl_statement,
        lists_pg_ddl_statement
      ].compact
    end

    def schema_ddl_statements
      [
        stuffs_ddl_statement,
        stuffs_index_statement,
        accounts_ddl_statement,
        lists_ddl_statement,
        items_ddl_statement,
        commit_timestamp_test_ddl_statement
      ].compact
    end

    def stuffs_table_types
      { id: :INT64,
          int: :INT64,
          float: :FLOAT64,
          bool: :BOOL,
          string: :STRING,
          byte: :BYTES,
          date: :DATE,
          timestamp: :TIMESTAMP,
          json: :JSON,
          ints: [:INT64],
          floats: [:FLOAT64],
          bools: [:BOOL],
          strings: [:STRING],
          bytes: [:BYTES],
          dates: [:DATE],
          timestamps: [:TIMESTAMP],
          jsons: [:JSON] }
    end

    def stuffs_random_row id = SecureRandom.int64
      { id: id,
        int: rand(0..1000),
        float: rand(0.0..100.0),
        bool: [true, false].sample,
        string: SecureRandom.hex(16),
        byte: File.open("acceptance/data/face.jpg", "rb"),
        date: Date.today + rand(-100..100),
        timestamp: Time.now + rand(-60 * 60 * 24.0..60 * 60 * 24.0),
        json: { venue: "Yellow Lake", rating: 10 },
        ints: rand(2..10).times.map { rand(0..1000) },
        floats: rand(2..10).times.map { rand(0.0..100.0) },
        bools: rand(2..10).times.map { [true, false].sample },
        strings: rand(2..10).times.map { SecureRandom.hex(16) },
        bytes: [File.open("acceptance/data/face.jpg", "rb"),
                File.open("acceptance/data/landmark.jpg", "rb"),
                File.open("acceptance/data/logo.jpg", "rb")],
        dates: rand(2..10).times.map { Date.today + rand(-100..100) },
        timestamps: rand(2..10).times.map { Time.now + rand(-60 * 60 * 24.0..60 * 60 * 24.0) },
        json_array: [{ venue: "Green Lake", rating: 8 }, { venue: "Blue Lake", rating: 9 }] }
    end

    def default_account_rows
      [
        {
          account_id: 1,
          username: "blowmage",
          reputation: 63.5,
          active: true,
          avatar: File.open("acceptance/data/logo.jpg", "rb"),
          friends: [2]
        }, {
          account_id: 2,
          username: "quartzmo",
          reputation: 87.9,
          active: true,
          avatar: StringIO.new("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAABxpRE9U\
            AAAAAgAAAAAAAAAgAAAAKAAAACAAAAAgAAABxj2CfowAAAGSSURBVHgB7Jc9TsNAEIX3JDkCPUV6KlpKFHEGlD4nyA04A\
            CUXQKTgCEipUnKGNEbP0otentayicZ24SlWs7tjO/N9u/5J2b2+NUtuZcnwYE8BuQPyGZAPwXwLLPk5kG+BJa9+fgfkh1\
            B+CeancL4F8i2Q/wWm/S/w+XFoTseftn0dvhu0OXfhpM+AGvzcEiYVAFisPqE9zrETJhHAlXfg2lglMK9z0f3RBfB+ZyR\
            UV3x+erzsEIjjOBqc1xtNAIrvguybV3A9lkVHxlEE6GrrPb/ZvAySwlUnfCmlPQ+R8JCExvGtcRQBLFwj4FGkznX1VYDKP\
            G/f2/MjwCksXACgdNUxJjwK9xwl4JihOwTFR0kIF+CABEPRnvsvPFctMoYKqAFSAFaMwB4pp3Y+bodIYL9WmIAaIOHxo7\
            W8wiHvAjTvhUeNwwSgeAeAABbqOewC5hBdwFD4+9+7puzXV9fS6/b1wwT4tsaYAhwOOQdUQch5vgZCeAhAv3ZM31yYAA\
            UgvApQQQ6n5w6FB/RVe1jdJOAPAAD//1eMQwoAAAGQSURBVO1UMU4DQQy8X9AgWopIUINEkS4VlJQo4gvwAV7AD3gEH4i\
            SgidESpWSXyyZExP5lr0c7K5PsXBhec/2+jzjuWtent9CLdtu1mG5+gjz+WNr7IsY7eH+tvO+xfuqk4vz7CH91edFaF5v\
            9nb6dBKm13edvrL+0Lk5lMzJkQDeJSkkgHF6mR8CHwMHCQR/NAQQGD0BAlwK4FCefQiefq+A2Vn29tG7igLAfmwcnJu/nJ\
            y3BMQkMN9HEPr8AL3bfBv7Bp+7/SoExMDjZwKEJwmyhnnmQIQEBIlz2x0iKoAvJkAC6TsTIH6MqRrEWUMSZF2zAwqT4Eu/e\
            6pzFAIkmNSZ4OFT+VYBIIF//UqbJwnF/4DU0GwOn8r/JQYCpPGufEfJuZiA37ycQw/5uFeqPq4pfR6FADmkBCXjfWdZj3Nf\
            XW58dAJyB9W65wRoMWulryvAyqa05nQFaDFrpa8rwMqmtOZ0BWgxa6WvK8DKprTmdAVoMWulryvAyqa05nQFaDFrpa8rw\
            MqmtOb89wr4AtQ4aPoL6yVpAAAAAElFTkSuQmCC"),
          friends: [1]
        }, {
          account_id: 3,
          username: "-inactive-",
          active: false
        }
      ]
    end

    def default_pg_account_rows
      [
        {
          account_id: 1,
          username: "blowmage",
          reputation: 63.5,
          active: true,
          avatar: File.open("acceptance/data/logo.jpg", "rb"),
          friends: [2]
        }, {
          account_id: 2,
          username: "quartzmo",
          reputation: 87.9,
          active: true,
          avatar: StringIO.new("iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAABxpRE9U\
            AAAAAgAAAAAAAAAgAAAAKAAAACAAAAAgAAABxj2CfowAAAGSSURBVHgB7Jc9TsNAEIX3JDkCPUV6KlpKFHEGlD4nyA04A\
            CUXQKTgCEipUnKGNEbP0otentayicZ24SlWs7tjO/N9u/5J2b2+NUtuZcnwYE8BuQPyGZAPwXwLLPk5kG+BJa9+fgfkh1\
            B+CeancL4F8i2Q/wWm/S/w+XFoTseftn0dvhu0OXfhpM+AGvzcEiYVAFisPqE9zrETJhHAlXfg2lglMK9z0f3RBfB+ZyR\
            UV3x+erzsEIjjOBqc1xtNAIrvguybV3A9lkVHxlEE6GrrPb/ZvAySwlUnfCmlPQ+R8JCExvGtcRQBLFwj4FGkznX1VYDKP\
            G/f2/MjwCksXACgdNUxJjwK9xwl4JihOwTFR0kIF+CABEPRnvsvPFctMoYKqAFSAFaMwB4pp3Y+bodIYL9WmIAaIOHxo7\
            W8wiHvAjTvhUeNwwSgeAeAABbqOewC5hBdwFD4+9+7puzXV9fS6/b1wwT4tsaYAhwOOQdUQch5vgZCeAhAv3ZM31yYAA\
            UgvApQQQ6n5w6FB/RVe1jdJOAPAAD//1eMQwoAAAGQSURBVO1UMU4DQQy8X9AgWopIUINEkS4VlJQo4gvwAV7AD3gEH4i\
            SgidESpWSXyyZExP5lr0c7K5PsXBhec/2+jzjuWtent9CLdtu1mG5+gjz+WNr7IsY7eH+tvO+xfuqk4vz7CH91edFaF5v\
            9nb6dBKm13edvrL+0Lk5lMzJkQDeJSkkgHF6mR8CHwMHCQR/NAQQGD0BAlwK4FCefQiefq+A2Vn29tG7igLAfmwcnJu/nJ\
            y3BMQkMN9HEPr8AL3bfBv7Bp+7/SoExMDjZwKEJwmyhnnmQIQEBIlz2x0iKoAvJkAC6TsTIH6MqRrEWUMSZF2zAwqT4Eu/e\
            6pzFAIkmNSZ4OFT+VYBIIF//UqbJwnF/4DU0GwOn8r/JQYCpPGufEfJuZiA37ycQw/5uFeqPq4pfR6FADmkBCXjfWdZj3Nf\
            XW58dAJyB9W65wRoMWulryvAyqa05nQFaDFrpa8rwMqmtOZ0BWgxa6WvK8DKprTmdAVoMWulryvAyqa05nQFaDFrpa8rw\
            MqmtOb89wr4AtQ4aPoL6yVpAAAAAElFTkSuQmCC"),
          friends: [1]
        }, {
          account_id: 3,
          username: "-inactive-",
          active: false
        }
      ]
    end
  end
end
