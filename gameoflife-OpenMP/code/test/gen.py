import argparse
import random


def create_file(n_generations, n_rows, m_cols, output_file, n_invasions):
    with open(output_file, "w") as f:
        f.write(f"{n_generations}\n{n_rows}\n{m_cols}\n")

        # Generate starting world
        for _ in range(n_rows):
            row = " ".join(
                str(random.randint(0, 9) if random.random() <= 0.2 else 0)
                for _ in range(m_cols)
            )
            f.write(f"{row}\n")

        n_invasions = n_invasions

        f.write(f"{n_invasions}\n")

        invasions_counter = 0
        for i in range(1, n_generations + 1):
            if invasions_counter < n_invasions and random.random() < (
                n_invasions - invasions_counter
            ) / (n_generations - i + 1):
                invasions_counter += 1

                f.write(f"{i}\n")

                # Generate invasion plan
                invader = str(random.randint(0, 9))
                for _ in range(n_rows):
                    row = " ".join(
                        (invader if random.random() <= 0.1 else "0")
                        for _ in range(m_cols)
                    )
                    f.write(f"{row}\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate a simulation input file.")
    parser.add_argument(
        "--n_generations",
        type=int,
        required=True,
        help="Number of new generations to be simulated",
    )
    parser.add_argument(
        "--n_rows", type=int, required=True, help="Number of rows in the 2D world"
    )
    parser.add_argument(
        "--m_cols", type=int, required=True, help="Number of columns in the 2D world"
    )

    parser.add_argument(
        "--nInvasions", type=int, required=True, help="Invasion pls"
    )

    parser.add_argument(
        "--output_file", type=str, required=True, help="Name of the output file"
    )

    args = parser.parse_args()

    create_file(args.n_generations, args.n_rows, args.m_cols, args.output_file, args.nInvasions)
