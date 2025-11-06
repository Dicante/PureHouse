type Props = {
  date: string | Date;
};

const DateFormatter = ({ date }: Props) => {
  // Ensure date is a Date object
  const dateObj = typeof date === "string" ? new Date(date) : date;
  const formatted = dateObj.toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
  return <time dateTime={dateObj.toISOString()}>{formatted}</time>;
};

export default DateFormatter;
